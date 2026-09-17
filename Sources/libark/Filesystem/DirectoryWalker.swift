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

public class DirectoryWalker: Sequence, IteratorProtocol {
    private var stack: [Directory] = []
    public let followSymlinks: Bool
    
    public init(root: Path, followSymlinks: Bool = false) {
        self.followSymlinks = followSymlinks
        if let dir = try? Directory.open(path: root) {
            stack.append(dir)
        }
    }
    
    public func next() -> DirectoryEntry? {
        while !stack.isEmpty {
            let currentDir = stack.last!
            
            if let entry = try? currentDir.read() {
                if entry.name == "." || entry.name == ".." {
                    continue
                }
                
                if entry.type == .directory {
                    if let newDir = try? Directory.open(path: entry.path) {
                        stack.append(newDir)
                    }
                } else if entry.type == .symbolicLink && followSymlinks {
                    if let meta = try? FileMetadata.stat(path: entry.path, resolve: .follow), meta.fileType == .directory {
                        if let newDir = try? Directory.open(path: entry.path) {
                            stack.append(newDir)
                        }
                    }
                }
                
                return entry
            } else {
                stack.removeLast()
            }
        }
        return nil
    }
}
