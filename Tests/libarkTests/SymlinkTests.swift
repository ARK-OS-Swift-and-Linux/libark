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
import Glibc

final class SymlinkTests: XCTestCase {
    
    var testDir: String!
    var targetFile: String!
    var linkFile: String!
    
    override func setUp() {
        super.setUp()
        testDir = "/tmp/libark_symlink_tests_\(UUID().uuidString)"
        mkdir(testDir, 0o777)
        
        targetFile = "\(testDir!)/target.txt"
        linkFile = "\(testDir!)/link.txt"
        
        let fd = open(targetFile, O_CREAT | O_WRONLY, 0o644)
        if fd >= 0 {
            let content = "hello"
            write(fd, content, content.utf8.count)
            close(fd)
        }
        
        symlink(targetFile, linkFile)
    }
    
    override func tearDown() {
        unlink(linkFile)
        unlink(targetFile)
        rmdir(testDir)
        super.tearDown()
    }
    
    func testReadlink() {
        let path = Path(linkFile)
        let target = SymlinkReader.readlink(path: path)
        XCTAssertEqual(target, targetFile)
    }
    
    func testLstat() throws {
        let path = Path(linkFile)
        let meta = try FileMetadata.lstat(path: path)
        XCTAssertTrue(meta.isSymlink)
        XCTAssertEqual(meta.symlinkTarget, targetFile)
    }
    
    func testStat() throws {
        let path = Path(linkFile)
        let meta = try FileMetadata.stat(path: path)
        XCTAssertFalse(meta.isSymlink)
        XCTAssertNil(meta.symlinkTarget)
        XCTAssertEqual(meta.size, 5) // size of "hello"
    }
    
    func testUnifiedStatFollow() throws {
        let path = Path(linkFile)
        let meta = try FileMetadata.stat(path: path, resolve: .follow)
        XCTAssertFalse(meta.isSymlink)
        XCTAssertNil(meta.symlinkTarget)
        XCTAssertEqual(meta.size, 5)
    }
    
    func testUnifiedStatNoFollow() throws {
        let path = Path(linkFile)
        let meta = try FileMetadata.stat(path: path, resolve: .noFollow)
        XCTAssertTrue(meta.isSymlink)
        XCTAssertEqual(meta.symlinkTarget, targetFile)
    }
}
