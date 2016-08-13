import XCTest
@testable import SecureHanger

class SecureHangerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(SecureHanger().text, "Hello, World!")
    }


    static var allTests : [(String, (SecureHangerTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
