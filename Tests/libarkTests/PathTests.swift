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

final class PathTests: XCTestCase {
    
    func testParsingAndString() {
        let p1 = Path("/a/b/c")
        XCTAssertEqual(p1.components, [.root, .name("a"), .name("b"), .name("c")])
        XCTAssertEqual(p1.string, "/a/b/c")
        XCTAssertTrue(p1.isAbsolute)
        
        let p2 = Path("a/b/../c/.")
        XCTAssertEqual(p2.components, [.name("a"), .name("b"), .parent, .name("c"), .current])
        XCTAssertEqual(p2.string, "a/b/../c/.")
        XCTAssertFalse(p2.isAbsolute)
        
        let p3 = Path("/")
        XCTAssertEqual(p3.components, [.root])
        XCTAssertEqual(p3.string, "/")
        
        let p4 = Path("")
        XCTAssertEqual(p4.components, [.current])
        XCTAssertEqual(p4.string, ".")
    }
    
    func testNormalization() {
        let p1 = Path("/a/b/../c").normalize()
        XCTAssertEqual(p1.string, "/a/c")
        
        let p2 = Path("a/./b/./c").normalize()
        XCTAssertEqual(p2.string, "a/b/c")
        
        let p3 = Path("/../..").normalize()
        XCTAssertEqual(p3.string, "/")
        
        let p4 = Path("a/b/../../..").normalize()
        XCTAssertEqual(p4.string, "..")
        
        let p5 = Path("./a").normalize()
        XCTAssertEqual(p5.string, "a")
    }
    
    func testProperties() {
        let p = Path("/var/log/syslog.1.gz")
        XCTAssertEqual(p.parent?.string, "/var/log")
        XCTAssertEqual(p.filename, "syslog.1.gz")
        XCTAssertEqual(p.extension, "gz")
        XCTAssertEqual(p.stem, "syslog.1")
        
        let hidden = Path("/home/user/.bashrc")
        XCTAssertEqual(hidden.filename, ".bashrc")
        XCTAssertNil(hidden.extension)
        XCTAssertEqual(hidden.stem, ".bashrc")
    }
    
    func testJoin() {
        let p1 = Path("/var")
        let p2 = p1.join("log/syslog")
        XCTAssertEqual(p2.string, "/var/log/syslog")
        
        let p3 = p1.join("/etc/passwd")
        XCTAssertEqual(p3.string, "/etc/passwd")
    }
    
    func testRelative() {
        let p1 = Path("/home/user/src/arkrt")
        let base = Path("/home/user")
        XCTAssertEqual(p1.relative(to: base).string, "src/arkrt")
        
        let p2 = Path("/etc/passwd")
        XCTAssertEqual(p2.relative(to: base).string, "../../etc/passwd")
    }
    
    func testResolve() {
        let p = Path("src/../log")
        let absolute = p.resolve(cwd: Path("/home/user"))
        XCTAssertEqual(absolute.string, "/home/user/log")
    }
    
    func testCanonicalize() throws {
        // Create a temporary structure
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        let target = tempDir.appendingPathComponent("target.txt")
        try "hello".write(to: target, atomically: true, encoding: .utf8)
        
        let symlink = tempDir.appendingPathComponent("link.txt")
        try FileManager.default.createSymbolicLink(atPath: symlink.path, withDestinationPath: target.path)
        
        let path = Path(symlink.path)
        let canonical = try path.canonicalize()
        XCTAssertEqual(canonical.string, target.path)
    }
}
