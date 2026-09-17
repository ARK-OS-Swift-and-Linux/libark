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

public struct UID {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

public struct GID {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

public struct User {
    public let uid: UID
    public let name: String
    
    public init(uid: UID, name: String) {
        self.uid = uid
        self.name = name
    }
    
    public static func current() -> User {
        let u = getuid()
        if let pwd = getpwuid(u) {
            let name = String(cString: pwd.pointee.pw_name)
            return User(uid: UID(rawValue: u), name: name)
        }
        return User(uid: UID(rawValue: u), name: "\(u)")
    }
}

public struct Group {
    public let gid: GID
    public let name: String
    
    public init(gid: GID, name: String) {
        self.gid = gid
        self.name = name
    }
    
    public static func current() -> Group {
        let g = getgid()
        if let grp = getgrgid(g) {
            let name = String(cString: grp.pointee.gr_name)
            return Group(gid: GID(rawValue: g), name: name)
        }
        return Group(gid: GID(rawValue: g), name: "\(g)")
    }
}
