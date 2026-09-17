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

import Glibc

public class Directory: Sequence, IteratorProtocol {
    private let dir: OpaquePointer
    public let path: Path
    
    private init(dir: OpaquePointer, path: Path) {
        self.dir = dir
        self.path = path
    }
    
    deinit {
        close()
    }
    
    public static func open(path: Path) throws -> Directory {
        let dir = path._with_unsafe_c_string { p in
            return opendir(p)
        }
        guard let validDir = dir else {
            throw SystemError(errNo: Int32(errno))
        }
        return Directory(dir: validDir, path: path)
    }
    
    public func read() throws -> DirectoryEntry? {
        errno = 0
        guard let ent = readdir(dir) else {
            if errno != 0 {
                throw SystemError(errNo: Int32(errno))
            }
            return nil
        }
        
        var dName = ent.pointee.d_name
        let name = withUnsafeBytes(of: &dName) { rawPtr -> String in
            let buffer = rawPtr.bindMemory(to: CChar.self)
            var len = 0
            while len < buffer.count && buffer[len] != 0 {
                len += 1
            }
            let uint8Ptr = rawPtr.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return String(decoding: UnsafeBufferPointer(start: uint8Ptr, count: len), as: UTF8.self)
        }
        
        let entryPath = path.join(name)
        let type = FileType(d_type: ent.pointee.d_type)
        return DirectoryEntry(name: name, path: entryPath, type: type)
    }
    
    public func close() {
        closedir(dir)
    }
    
    public func next() -> DirectoryEntry? {
        do {
            return try read()
        } catch {
            return nil
        }
    }
}
