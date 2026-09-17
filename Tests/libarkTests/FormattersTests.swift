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

final class FormattersTests: XCTestCase {
    
    private func createMetadata(name: String, mode: UInt32, uid: UInt32 = 1000, gid: UInt32 = 1000) -> FileMetadata {
        var st = stat()
        st.st_mode = mode
        st.st_uid = uid
        st.st_gid = gid
        return FileMetadata(stat: st, path: Path(name))
    }
    
    func testFileTypeFormatter() {
        XCTAssertEqual(FileTypeFormatter.character(for: .regular), "-")
        XCTAssertEqual(FileTypeFormatter.character(for: .directory), "d")
        XCTAssertEqual(FileTypeFormatter.character(for: .symbolicLink), "l")
        XCTAssertEqual(FileTypeFormatter.character(for: .characterDevice), "c")
        XCTAssertEqual(FileTypeFormatter.character(for: .blockDevice), "b")
        XCTAssertEqual(FileTypeFormatter.character(for: .fifo), "p")
        XCTAssertEqual(FileTypeFormatter.character(for: .socket), "s")
        XCTAssertEqual(FileTypeFormatter.character(for: .unknown), "-")
    }
    
    func testPermissionFormatter() {
        let dir = createMetadata(name: "dir", mode: S_IFDIR | 0o755)
        XCTAssertEqual(PermissionFormatter.format(metadata: dir), "drwxr-xr-x")
        
        let file = createMetadata(name: "file", mode: S_IFREG | 0o644)
        XCTAssertEqual(PermissionFormatter.format(metadata: file), "-rw-r--r--")
        
        let symlink = createMetadata(name: "link", mode: S_IFLNK | 0o777)
        XCTAssertEqual(PermissionFormatter.format(metadata: symlink), "lrwxrwxrwx")
    }
    
    func testOwnerFormatter() {
        XCTAssertEqual(OwnerFormatter.format(uid: 1001), "1001")
        XCTAssertEqual(OwnerFormatter.format(gid: 2002), "2002")
    }
    
    func testNameFormatterUnclassified() {
        let file = createMetadata(name: "script.sh", mode: S_IFREG | 0o755)
        let formatter = NameFormatter(classify: false)
        XCTAssertEqual(formatter.format(metadata: file), "script.sh")
    }
    
    func testNameFormatterClassified() {
        let formatter = NameFormatter(classify: true)
        
        let dir = createMetadata(name: "folder", mode: S_IFDIR | 0o755)
        XCTAssertEqual(formatter.format(metadata: dir), "folder/")
        
        let exec = createMetadata(name: "script.sh", mode: S_IFREG | 0o755)
        XCTAssertEqual(formatter.format(metadata: exec), "script.sh*")
        
        let regular = createMetadata(name: "file.txt", mode: S_IFREG | 0o644)
        XCTAssertEqual(formatter.format(metadata: regular), "file.txt")
        
        let symlink = createMetadata(name: "link", mode: S_IFLNK | 0o777)
        XCTAssertEqual(formatter.format(metadata: symlink), "link@")
        
        let socket = createMetadata(name: "sock", mode: S_IFSOCK | 0o777)
        XCTAssertEqual(formatter.format(metadata: socket), "sock=")
        
        let fifo = createMetadata(name: "pipe", mode: S_IFIFO | 0o666)
        XCTAssertEqual(formatter.format(metadata: fifo), "pipe|")
    }
}
