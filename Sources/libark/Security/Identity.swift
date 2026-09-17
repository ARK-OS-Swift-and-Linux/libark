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
