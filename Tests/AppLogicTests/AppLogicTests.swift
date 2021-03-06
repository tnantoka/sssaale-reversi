import XCTest
import HTTP
import Vapor
@testable import AppLogic

class AppLogicTests: XCTestCase {
    static let allTests = [
        ("testRoot", testRoot),
        ("testExample", testExample),
    ]
    
    func testRoot() {
        let drop = try! makeTestDroplet()
        let req = try! Request(method: .get, uri: "/")
        let res = try! drop.respond(to: req)
        let body = res.body.bytes!.string
        XCTAssertTrue(body.contains(title))
    }
    
    func testExample() {
        let drop = try! makeTestDroplet()
        let json = try! JSON(node: .object([
            "input" : "",
            "history" : [],
            "snapshot" : [],
            "strong" : false,
        ]))
        let req = try! Request(
            method: .post,
            uri: "/example",
            headers: [ HeaderKey.contentType : "application/json" ],
            body: json.makeBody()
        )
        let res = try! drop.respond(to: req)
        let body = res.body.bytes!.string
        XCTAssertTrue(body.contains("\"numBlack\":2,\"numWhite\":2"))
    }
}
