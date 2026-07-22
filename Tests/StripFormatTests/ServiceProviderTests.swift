import XCTest
@testable import StripFormat

/// Fake pasteboard that records what `ServiceProvider.stripFormat(on:)` does to it,
/// so the guard/logging logic can be tested without touching the real system pasteboard.
private final class FakePasteboard: PasteboardWriting {
    var types: [NSPasteboard.PasteboardType]?
    var stringToReturn: String?
    var setStringResult = true
    private(set) var clearContentsCallCount = 0
    private(set) var lastWrittenString: String?

    func string(forType dataType: NSPasteboard.PasteboardType) -> String? {
        stringToReturn
    }

    @discardableResult
    func clearContents() -> Int {
        clearContentsCallCount += 1
        return clearContentsCallCount
    }

    func setString(_ string: String, forType dataType: NSPasteboard.PasteboardType) -> Bool {
        lastWrittenString = string
        return setStringResult
    }
}

final class ServiceProviderTests: XCTestCase {
    func testReturnsErrorWhenNoPlainTextOnPasteboard() {
        let pasteboard = FakePasteboard()
        pasteboard.stringToReturn = nil

        let error = ServiceProvider.stripFormat(on: pasteboard)

        XCTAssertEqual(error, "No plain text on pasteboard.")
        XCTAssertEqual(pasteboard.clearContentsCallCount, 0)
    }

    func testWritesPlainTextBackUnchanged() {
        let pasteboard = FakePasteboard()
        pasteboard.stringToReturn = "some <b>rich</b> text"

        let error = ServiceProvider.stripFormat(on: pasteboard)

        XCTAssertNil(error)
        XCTAssertEqual(pasteboard.clearContentsCallCount, 1)
        XCTAssertEqual(pasteboard.lastWrittenString, "some <b>rich</b> text")
    }
}
