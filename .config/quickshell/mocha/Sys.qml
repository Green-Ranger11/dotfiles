pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// CPU / memory / temperature, polled from procfs on one timer.
// Same 10s interval waybar used.
Singleton {
    id: root

    property int cpu: 0
    property int memory: 0
    property int temperature: 0

    property var lastStat: null

    FileView { id: stat; path: "/proc/stat"; blockLoading: true }
    FileView { id: meminfo; path: "/proc/meminfo"; blockLoading: true }
    // thermal-zone 0, same zone waybar read.
    FileView { id: thermal; path: "/sys/class/thermal/thermal_zone0/temp"; blockLoading: true }

    function sample() {
        stat.reload();
        meminfo.reload();
        thermal.reload();

        const cpuLine = stat.text().split("\n")[0].split(/\s+/).slice(1).map(Number);
        if (cpuLine.length > 4) {
            const idle = cpuLine[3] + cpuLine[4];
            const total = cpuLine.reduce((a, b) => a + b, 0);
            if (root.lastStat) {
                const dIdle = idle - root.lastStat.idle;
                const dTotal = total - root.lastStat.total;
                if (dTotal > 0) root.cpu = Math.round(100 * (dTotal - dIdle) / dTotal);
            }
            root.lastStat = { idle, total };
        }

        const mem = {};
        for (const line of meminfo.text().split("\n")) {
            const m = line.match(/^(\w+):\s+(\d+)/);
            if (m) mem[m[1]] = Number(m[2]);
        }
        if (mem.MemTotal) root.memory = Math.round(100 * (mem.MemTotal - mem.MemAvailable) / mem.MemTotal);

        root.temperature = Math.round(Number(thermal.text()) / 1000);
    }

    // First tick only seeds the CPU baseline, so take a second one quickly
    // instead of showing 0% for ten seconds.
    Timer {
        running: true
        interval: 1000
        onTriggered: root.sample()
    }

    Timer {
        running: true
        interval: 10000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.sample()
    }
}
