// Scratch harness. Quickshell refuses relative imports that escape the config
// root, so `qs -p .../mocha/notifications` cannot see Theme in ".." and fails.
// Test it from a mirror root instead:
//
//   mkdir /tmp/nroot && cd /tmp/nroot
//   cp ~/.config/quickshell/mocha/{Theme,Label,Segment,Divider,Chip,Sys}.qml qmldir .
//   ln -s ~/.config/quickshell/mocha/notifications notifications
//   printf 'import Quickshell\nimport "notifications"\nShellRoot { NotificationLayer {} }\n' > shell.qml
//   qs -p /tmp/nroot
//
// swaync must be stopped first; it owns org.freedesktop.Notifications.
import Quickshell

ShellRoot {
    NotificationLayer {}
}
