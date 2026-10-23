// Hide sketchybar while the auto-hidden native menu bar is revealed, so the
// two don't draw on top of each other. The WindowServer "Menubar" window sits
// above the screen (negative y) when hidden and moves to y = 0 when shown;
// macOS posts no event for this, so poll it.
#include <CoreGraphics/CoreGraphics.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>

static bool menubar_shown(void) {
  CFArrayRef windows = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
  if (!windows) return false;

  bool shown = false;
  for (CFIndex i = 0; i < CFArrayGetCount(windows) && !shown; i++) {
    CFDictionaryRef w = CFArrayGetValueAtIndex(windows, i);
    CFStringRef name = CFDictionaryGetValue(w, kCGWindowName);
    if (!name || CFStringCompare(name, CFSTR("Menubar"), 0) != kCFCompareEqualTo) continue;

    CGRect bounds;
    CFDictionaryRef b = CFDictionaryGetValue(w, kCGWindowBounds);
    if (b && CGRectMakeWithDictionaryRepresentation(b, &bounds) && bounds.origin.y >= 0)
      shown = true;
  }
  CFRelease(windows);
  return shown;
}

int main(void) {
  int last = -1;
  for (;;) {
    int shown = menubar_shown();
    if (shown != last) {
      system(shown ? "sketchybar --bar hidden=on" : "sketchybar --bar hidden=off");
      last = shown;
    }
    usleep(100000);
  }
}
