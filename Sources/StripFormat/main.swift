import Cocoa
import os

private let serviceLog = Logger(subsystem: "com.peterichardson.stripformat", category: "service")

class ServiceProvider: NSObject {
    @objc func stripFormat(
        _ pboard: NSPasteboard,
        userData: String,
        error: AutoreleasingUnsafeMutablePointer<NSString>
    ) {
        let incomingTypes = pboard.types?.map(\.rawValue).joined(separator: ", ") ?? "none"
        serviceLog.debug("stripFormat invoked; incoming pasteboard types: \(incomingTypes)")

        guard let text = pboard.string(forType: .string) else {
            serviceLog.error("no plain text found on pasteboard")
            error.pointee = "No plain text on pasteboard." as NSString
            return
        }
        // Log only the character count, never the text itself: clipboard content can carry
        // passwords or other sensitive data, and the old os_log call logged the full string
        // with `%{public}@`, writing it in plaintext to the system-wide unified log (visible
        // via Console.app/`log show` and potentially bundled into a sysdiagnose).
        serviceLog.debug("read plain text (\(text.count) chars)")

        pboard.clearContents()
        let ok = pboard.setString(text, forType: .string)
        serviceLog.debug("wrote plain text back to pasteboard; setString succeeded: \(ok)")
    }
}

let app = NSApplication.shared
let provider = ServiceProvider()
app.servicesProvider = provider
app.setActivationPolicy(.accessory)  // no Dock icon, equivalent to LSUIElement
app.run()
