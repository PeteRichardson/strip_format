# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

StripFormat is a macOS Services-menu app. It registers a system Service ("Strip Text Format") that any app can invoke (via the Services menu or a bound keyboard shortcut) to take the current text selection off the pasteboard and write it back. It has no Dock icon and no windows (`LSUIElement` / `.accessory` activation policy) — it runs only to service that one Service call and otherwise sits idle in the background.

## Build & run

```bash
swift build                # debug build
swift build -c release     # release build
./build.sh                 # release build, then installs to /Applications/StripFormat.app
                            # and re-registers it with Launch Services (lsregister)
```

There is no test target — verification is manual: install the app, then select text in another
app, open the Services menu (or its bound shortcut), and choose "Strip Text Format".

**Gotcha:** apps read the Services list once (at launch) and cache it. After `build.sh`
re-registers the service, any target app that was already running (TextEdit, Stickies, etc.)
must be fully quit (Cmd+Q) and reopened before it will see the change — otherwise the Services
menu entry is stale and invoking it silently no-ops. A full logout/login also works but is
rarely necessary; relaunching the target app is sufficient. `lsregister -dump | grep -A5
com.peterichardson.stripformat` confirms what's actually registered if it's unclear whether a
rebuild took effect.

## Architecture

Single-file Swift executable (`Sources/StripFormat/main.swift`), packaged as an `.app` bundle
(via `build.sh` + `Info.plist`) rather than a plain CLI, because macOS Services only work from an
app bundle registered with Launch Services.

- `Info.plist` declares the `NSServices` entry: menu title "Strip Text Format", `NSMessage`
  `stripFormat`, sending/returning `NSStringPboardType`. This is what makes the app discoverable
  in the system Services menu.
- `main.swift` defines `ServiceProvider`, whose `@objc stripFormat(_:userData:error:)` method
  signature must match the `NSMessage` name in `Info.plist` — AppKit invokes it by Objective-C
  selector name via `NSApplication.servicesProvider`, so the two are coupled even though nothing
  in the Swift code references the plist directly.
- The actual "stripping" isn't a transformation of the text at all: `stripFormat` reads only
  the plain-text (`public.utf8-plain-text`) pasteboard representation and writes that exact
  same string back unchanged. Whatever richer representations (RTF/HTML) the original
  selection also carried are simply never read, so they're dropped — the effect comes from
  which representation is read, not from any mutation of the string itself.

When changing the transform logic, edit the body of `stripFormat` in `main.swift`. When changing
the menu label, invocation name, or supported pasteboard types, edit `Info.plist`'s `NSServices`
entry — and keep the Objective-C method name in sync with `NSMessage`.
