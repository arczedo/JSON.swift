import XCTest
@testable import json

final class jsonTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.



        print(JSON([1,2,3]).prettyPrinted())

        XCTAssertEqual(json().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
