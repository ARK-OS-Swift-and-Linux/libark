#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A strong, typed subsystem for file access permissions, replacing raw `mode_t` bit manipulation.
public struct Permissions: Equatable {
    
    /// A conceptual class representing the Read, Write, and Execute bits for owner, group, or other.
    public struct ClassPermissions: Equatable {
        public let read: Bool
        public let write: Bool
        public let execute: Bool
        
        public init(read: Bool, write: Bool, execute: Bool) {
            self.read = read
            self.write = write
            self.execute = execute
        }
        
        public init(mode: mode_t, shift: Int) {
            self.read = (mode & (0o4 << shift)) != 0
            self.write = (mode & (0o2 << shift)) != 0
            self.execute = (mode & (0o1 << shift)) != 0
        }
    }
    
    public let owner: ClassPermissions
    public let group: ClassPermissions
    public let other: ClassPermissions
    
    public let setuid: Bool
    public let setgid: Bool
    public let sticky: Bool
    
    public init(owner: ClassPermissions, group: ClassPermissions, other: ClassPermissions, setuid: Bool = false, setgid: Bool = false, sticky: Bool = false) {
        self.owner = owner
        self.group = group
        self.other = other
        self.setuid = setuid
        self.setgid = setgid
        self.sticky = sticky
    }
    
    public init(mode: mode_t) {
        self.owner = ClassPermissions(mode: mode, shift: 6)
        self.group = ClassPermissions(mode: mode, shift: 3)
        self.other = ClassPermissions(mode: mode, shift: 0)
        
        self.setuid = (mode & 0o4000) != 0
        self.setgid = (mode & 0o2000) != 0
        self.sticky = (mode & 0o1000) != 0
    }
    
    /// The string representation matching standard POSIX `ls -l` permissions.
    /// Ex: `rwxr-xr-x`, `rwsr-xr-x`, `rw-r--r--`, `rwxrwxrwt`.
    public var stringRepresentation: String {
        var perm = ""
        
        // Owner
        perm += owner.read ? "r" : "-"
        perm += owner.write ? "w" : "-"
        if setuid {
            perm += owner.execute ? "s" : "S"
        } else {
            perm += owner.execute ? "x" : "-"
        }
        
        // Group
        perm += group.read ? "r" : "-"
        perm += group.write ? "w" : "-"
        if setgid {
            perm += group.execute ? "s" : "S"
        } else {
            perm += group.execute ? "x" : "-"
        }
        
        // Other
        perm += other.read ? "r" : "-"
        perm += other.write ? "w" : "-"
        if sticky {
            perm += other.execute ? "t" : "T"
        } else {
            perm += other.execute ? "x" : "-"
        }
        
        return perm
    }
    
    /// Returns the permissions represented as an octal `mode_t`.
    public var octalValue: mode_t {
        var mode: mode_t = 0
        
        if owner.read { mode |= 0o400 }
        if owner.write { mode |= 0o200 }
        if owner.execute { mode |= 0o100 }
        
        if group.read { mode |= 0o040 }
        if group.write { mode |= 0o020 }
        if group.execute { mode |= 0o010 }
        
        if other.read { mode |= 0o004 }
        if other.write { mode |= 0o002 }
        if other.execute { mode |= 0o001 }
        
        if setuid { mode |= 0o4000 }
        if setgid { mode |= 0o2000 }
        if sticky { mode |= 0o1000 }
        
        return mode
    }
}
