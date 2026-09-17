import XCTest
@testable import libark

final class TerminalTests: XCTestCase {
    
    func testStandardStreams() throws {
        XCTAssertEqual(Terminal.stdin.fd, 0)
        XCTAssertEqual(Terminal.stdout.fd, 1)
        XCTAssertEqual(Terminal.stderr.fd, 2)
    }
    
    func testTerminalProperties() throws {
        // Since tests often run without a TTY or inside a runner,
        // we mainly want to ensure that calling these doesn't crash
        // and falls back safely if it's not a TTY.
        
        let out = Terminal.stdout
        
        // It's either a TTY or it isn't.
        let isTty = out.isTTY
        
        // Width and height should return valid positive integers
        // even if fallback is used.
        let w = out.width
        let h = out.height
        
        XCTAssertTrue(w > 0, "Width should be positive")
        XCTAssertTrue(h > 0, "Height should be positive")
        
        // Colors should match isTTY
        XCTAssertEqual(out.colors, isTty)
    }
}
