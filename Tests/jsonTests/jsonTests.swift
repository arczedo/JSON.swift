import XCTest
@testable import json

final class jsonTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        XCTAssertEqual(JSON([1,2,3]).prettyPrinted()!, "[\n  1,\n  2,\n  3\n]")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
