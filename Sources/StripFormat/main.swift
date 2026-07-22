import Cocoa
import os.log

private let serviceLog = OSLog(subsystem: "com.peterichardson.stripformat", category: "service")

class ServiceProvider: NSObject {
    @objc func stripFormat(
        _ pboard: NSPasteboard,
        userData: String,
        error: AutoreleasingUnsafeMutablePointer<NSString>
    ) {
        let incomingTypes = pboard.types?.map(\.rawValue).joined(separator: ", ") ?? "none"
        os_log("stripFormat invoked; incoming pasteboard types: %{public}@", log: serviceLog, type: .default, incomingTypes)

        guard let text = pboard.string(forType: .string) else {
            os_log("no plain text found on pasteboard", log: serviceLog, type: .error)
            error.pointee = "No plain text on pasteboard." as NSString
            return
        }
        os_log("read plain text (%{public}d chars): %{public}@", log: serviceLog, type: .default, text.count, text)

        pboard.clearContents()
        let ok = pboard.setString(text, forType: .string)
        os_log("wrote plain text back to pasteboard; setString succeeded: %{public}@", log: serviceLog, type: .default, ok ? "yes" : "no")
    }
}

let app = NSApplication.shared
let provider = ServiceProvider()
app.servicesProvider = provider
app.setActivationPolicy(.accessory)  // no Dock icon, equivalent to LSUIElement
app.run()
