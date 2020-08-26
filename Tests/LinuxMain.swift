import XCTest

import jsonTests

var tests = [XCTestCaseEntry]()
tests += jsonTests.allTests()
XCTMain(tests)
