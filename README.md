# Contra

**Contra** inverts scroll direction for external mice on macOS without touching trackpad or Magic Mouse behavior.

macOS ties "natural scrolling" to all pointing devices at once. If you like natural scrolling on a trackpad but want traditional (non-natural) scrolling on a external USB/Bluetooth mouse, macOS gives you no built-in way to do that. Contra fixes this at the driver level using a DriverKit extension (DEXT), so scroll events from external mice are inverted before they ever reach the rest of the system.

## How it works

Contra ships a **DriverKit HID extension (DEXT)** that matches external pointing devices and rewrites their scroll-wheel reports on the fly, flipping the vertical (and optionally horizontal) scroll axis. Because this happens at the HID driver layer:

- It works system-wide, in every app, without per-app configuration.
- It doesn't require kernel extensions (KEXTs), which Apple has deprecated in favor of DriverKit/System Extensions.
- Your trackpad and Magic Mouse/Trackpad continue to use macOS's native "natural scrolling" setting untouched.
- No event-tap injection or Accessibility-permission hacks — this is a real driver, not a userspace workaround.

## Requirements

- macOS 26.0 (Tahoe) or later

## Why a DEXT instead of a scroll-remapping app?

Several existing tools invert scroll by intercepting and re-posting HID events in userspace (via `CGEventTap` or similar). This works but has drawbacks:

- Requires Accessibility permissions and runs a background process reading all input events.
- Can introduce latency or event-ordering issues.
- Fragile across macOS updates to event-tap APIs.

Contra instead operates at the driver level, transforming the raw HID report before it's translated into system scroll events — the same layer Apple's own mouse drivers operate at.

## Known limitations

- Some mice with custom HID descriptors (e.g., gaming mice with vendor drivers) may not be matched by default; device-specific matching rules may need to be added.
- Per-app scroll direction (rather than per-device) is out of scope — that would require userspace event interception, defeating the purpose of the driver approach.
- Momentum/inertial scrolling behavior follows whatever the source device already reports; Contra inverts direction, it does not synthesize inertia.

## Contributing

Issues and pull requests are welcome. If you're adding support for a new device, please include the device's vendor/product ID and a description of its HID report descriptor for the scroll axis.

## License

MIT
