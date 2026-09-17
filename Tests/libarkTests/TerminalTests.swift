// Copyright 2026 Aarav Ravindra Kharade
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
