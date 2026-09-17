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

public struct DirectoryEntry {
    public let name: String
    public let path: Path
    public let type: FileType
    
    public init(name: String, path: Path, type: FileType) {
        self.name = name
        self.path = path
        self.type = type
    }
}

extension FileType {
    public init(d_type: UInt8) {
        switch Int(d_type) {
        case Int(DT_REG): self = .regular
        case Int(DT_DIR): self = .directory
        case Int(DT_LNK): self = .symbolicLink
        case Int(DT_CHR): self = .characterDevice
        case Int(DT_BLK): self = .blockDevice
        case Int(DT_FIFO): self = .fifo
        case Int(DT_SOCK): self = .socket
        default: self = .unknown
        }
    }
}
