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

public struct FileOperations {
    /// Reads the entire contents of a file as a String.
    public static func readFile(at path: String) throws -> String {
        let p = Path(path)
        let fd = try FileDescriptor.open(path: p, flags: O_RDONLY)
        defer { try? fd.close() }
        
        let meta = try fd.stat()
        let size = Int(meta.size)
        if size == 0 {
            // Might be a special file or empty. Read in chunks.
            var result = ""
            var buffer = [UInt8](repeating: 0, count: 4096)
            while true {
                let bytesRead = try buffer.withUnsafeMutableBytes { ptr -> Int in
                    return try fd.read(into: ptr)
                }
                if bytesRead <= 0 { break }
                result += String(decoding: buffer[0..<bytesRead], as: UTF8.self)
            }
            return result
        } else {
            var data = [UInt8](repeating: 0, count: size)
            let bytesRead = try data.withUnsafeMutableBytes { ptr -> Int in
                return try fd.read(into: ptr)
            }
            return String(decoding: data[0..<bytesRead], as: UTF8.self)
        }
    }
    
    /// Writes a String to a file, overwriting existing contents or creating a new file.
    public static func writeFile(at path: String, contents: String, mode: mode_t = 0o644) throws {
        let p = Path(path)
        let flags = O_WRONLY | O_CREAT | O_TRUNC
        let fd = try FileDescriptor.open(path: p, flags: flags, mode: mode)
        defer { try? fd.close() }
        
        let data = Array(contents.utf8)
        var bytesWritten = 0
        while bytesWritten < data.count {
            let written = try data[bytesWritten...].withUnsafeBytes { ptr -> Int in
                return try fd.write(from: ptr)
            }
            if written <= 0 { break }
            bytesWritten += written
        }
    }
}
