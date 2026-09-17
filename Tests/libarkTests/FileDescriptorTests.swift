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
import Glibc
@testable import libark

final class FileDescriptorTests: XCTestCase {
    let testFilePath = Path("/tmp/libark_fd_test_\(UUID().uuidString)")
    
    override func setUp() {
        super.setUp()
        // Ensure clean state
        let _ = unlink(testFilePath.string)
    }
    
    override func tearDown() {
        // Clean up
        let _ = unlink(testFilePath.string)
        super.tearDown()
    }
    
    func testFileDescriptorOperations() throws {
        // 1. Open with O_CREAT | O_WRONLY
        let flags = Int32(O_CREAT | O_WRONLY | O_TRUNC)
        let fd = try FileDescriptor.open(path: testFilePath, flags: flags, mode: mode_t(0o644))
        
        // 2. Write data
        let content = "Hello, FileDescriptor!"
        let bytesWritten = try content.withCString { ptr -> Int in
            let buffer = UnsafeRawBufferPointer(start: ptr, count: content.utf8.count)
            return try fd.write(from: buffer)
        }
        XCTAssertEqual(bytesWritten, content.utf8.count)
        
        // 3. Stat (should get 644 perms and correct size)
        let meta = try fd.stat()
        XCTAssertEqual(meta.size, content.utf8.count)
        XCTAssertEqual(meta.permissions.octalValue & 0o777, 0o644)
        
        // 4. pwrite at offset
        let extraContent = " appended"
        let pwriteBytes = try extraContent.withCString { ptr -> Int in
            let buffer = UnsafeRawBufferPointer(start: ptr, count: extraContent.utf8.count)
            return try fd.pwrite(from: buffer, offset: off_t(content.utf8.count))
        }
        XCTAssertEqual(pwriteBytes, extraContent.utf8.count)
        
        // 5. sync
        try fd.sync()
        
        // 6. chmod
        let newPerms = Permissions(mode: 0o600)
        try fd.chmod(mode: newPerms)
        let newMeta = try fd.stat()
        XCTAssertEqual(newMeta.permissions.octalValue & 0o777, 0o600)
        
        // 7. close
        try fd.close()
        
        // 8. Open again with O_RDONLY
        let readFd = try FileDescriptor.open(path: testFilePath, flags: Int32(O_RDONLY))
        
        // 9. pread
        let readBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 1024, alignment: 1)
        defer { readBuffer.deallocate() }
        
        let preadBytes = try readFd.pread(into: readBuffer, offset: 0)
        XCTAssertEqual(preadBytes, content.utf8.count + extraContent.utf8.count)
        
        let readString = String(decoding: UnsafeRawBufferPointer(start: readBuffer.baseAddress, count: preadBytes), as: UTF8.self)
        XCTAssertEqual(readString, "Hello, FileDescriptor! appended")
        
        // 10. seek and read
        let newOffset = try readFd.seek(offset: 7, whence: SEEK_SET)
        XCTAssertEqual(newOffset, 7)
        
        let readBytes = try readFd.read(into: readBuffer)
        XCTAssertEqual(readBytes, preadBytes - 7)
        
        let readString2 = String(decoding: UnsafeRawBufferPointer(start: readBuffer.baseAddress, count: readBytes), as: UTF8.self)
        XCTAssertEqual(readString2, "FileDescriptor! appended")
        
        // 11. close
        try readFd.close()
    }
}
