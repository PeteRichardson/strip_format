import Cocoa
import os.log

private let serviceLog = OSLog(subsystem: "com.peterichardson.stripformat", category: "service")

/// Narrow view of the pasteboard operations `ServiceProvider` needs. Exists so the
/// guard/logging logic in `stripFormat(on:)` can run against a fake in unit tests
/// (see `StripFormatTests`) instead of only ever being exercised via the real
/// system pasteboard and a live Services invocation.
protocol PasteboardWriting {
    var types: [NSPasteboard.PasteboardType]? { get }
    func string(forType dataType: NSPasteboard.PasteboardType) -> String?
    @discardableResult func clearContents() -> Int
    func setString(_ string: String, forType dataType: NSPasteboard.PasteboardType) -> Bool
}

extension NSPasteboard: PasteboardWriting {}

class ServiceProvider: NSObject {
    @objc func stripFormat(
        _ pboard: NSPasteboard,
        userData: String,
        error: AutoreleasingUnsafeMutablePointer<NSString>
    ) {
        if let message = Self.stripFormat(on: pboard) {
            error.pointee = message as NSString
        }
    }

    /// Core transform logic, pulled out of the `@objc` entry point above because that
    /// entry point's signature is fixed by NSServices to take a concrete `NSPasteboard`
    /// (an Objective-C bridging requirement) — this static function takes the
    /// `PasteboardWriting` protocol instead, so it's the piece `StripFormatTests` actually
    /// exercises. Returns an error message on failure, or `nil` on success.
    @discardableResult
    static func stripFormat(on pboard: PasteboardWriting) -> String? {
        let incomingTypes = pboard.types?.map(\.rawValue).joined(separator: ", ") ?? "none"
        os_log("stripFormat invoked; incoming pasteboard types: %{public}@", log: serviceLog, type: .default, incomingTypes)

        guard let text = pboard.string(forType: .string) else {
            os_log("no plain text found on pasteboard", log: serviceLog, type: .error)
            return "No plain text on pasteboard."
        }
        os_log("read plain text (%{public}d chars): %{public}@", log: serviceLog, type: .default, text.count, text)

        pboard.clearContents()
        let ok = pboard.setString(text, forType: .string)
        os_log("wrote plain text back to pasteboard; setString succeeded: %{public}@", log: serviceLog, type: .default, ok ? "yes" : "no")
        return nil
    }
}
