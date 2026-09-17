import Glibc
import SystemPackage

public struct FileMetadata {
    private let _stat: stat
    public let path: Path
    public let symlinkTarget: String?
    
    init(stat: stat, path: Path, symlinkTarget: String? = nil) {
        self._stat = stat
        self.path = path
        self.symlinkTarget = symlinkTarget
    }
    
    // MARK: - Properties
    
    public var inode: UInt64 { return UInt64(_stat.st_ino) }
    public var device: UInt64 { return UInt64(_stat.st_dev) }
    
    public var fileType: FileType {
        let mode = _stat.st_mode & S_IFMT
        switch mode {
        case S_IFREG: return .regular
        case S_IFDIR: return .directory
        case S_IFLNK: return .symbolicLink
        case S_IFCHR: return .characterDevice
        case S_IFBLK: return .blockDevice
        case S_IFIFO: return .fifo
        case S_IFSOCK: return .socket
        default: return .unknown
        }
    }
    
    public var mode: UInt32 { return _stat.st_mode }
    public var permissions: Permissions { return Permissions(mode: _stat.st_mode) }
    
    public var uid: UInt32 { return _stat.st_uid }
    public var gid: UInt32 { return _stat.st_gid }
    
    public var size: Int { return Int(_stat.st_size) }
    public var blocks: Int { return Int(_stat.st_blocks) }
    public var blockSize: Int { return Int(_stat.st_blksize) }
    public var linkCount: Int { return Int(_stat.st_nlink) }
    
    public var accessTime: timespec { return _stat.st_atim }
    public var modificationTime: timespec { return _stat.st_mtim }
    public var changeTime: timespec { return _stat.st_ctim }
    public var birthTime: timespec? { return nil } // statx required for btime on Linux
    
    public var major: Int { return Int((_stat.st_rdev >> 8) & 0xfff) | Int((_stat.st_rdev >> 32) & ~0xfff) }
    public var minor: Int { return Int(_stat.st_rdev & 0xff) | Int((_stat.st_rdev >> 12) & ~0xff) }
    
    public var isSymlink: Bool { return fileType == .symbolicLink }
    
    // MARK: - API
    
    public static func stat(path: Path, resolve: SymlinkResolution) throws -> FileMetadata {
        switch resolve {
        case .follow:
            return try stat(path: path)
        case .noFollow:
            return try lstat(path: path)
        }
    }
    
    public static func stat(path: Path) throws -> FileMetadata {
        var st = Glibc.stat()
        let ret = path._with_unsafe_c_string { p in
            return Syscall._execute_secure(sys_no: 4, ptr1: UnsafeRawPointer(p), ptr2: UnsafeRawPointer(withUnsafeMutablePointer(to: &st) { $0 }))
        }
        if ret != 0 { throw SystemError(errNo: Int32(errno)) }
        return FileMetadata(stat: st, path: path)
    }
    
    public static func lstat(path: Path) throws -> FileMetadata {
        var st = Glibc.stat()
        let ret = path._with_unsafe_c_string { p in
            return Syscall._execute_secure(sys_no: 6, ptr1: UnsafeRawPointer(p), ptr2: UnsafeRawPointer(withUnsafeMutablePointer(to: &st) { $0 }))
        }
        if ret != 0 { throw SystemError(errNo: Int32(errno)) }
        
        var target: String? = nil
        if (st.st_mode & S_IFMT) == S_IFLNK {
            target = SymlinkReader.readlink(path: path)
        }
        
        return FileMetadata(stat: st, path: path, symlinkTarget: target)
    }
    
    public static func fstat(fd: Int32) throws -> FileMetadata {
        var st = Glibc.stat()
        let ret = Syscall._execute_secure(sys_no: 5, ptr1: UnsafeRawPointer(bitPattern: Int(fd)), ptr2: UnsafeRawPointer(withUnsafeMutablePointer(to: &st) { $0 }))
        if ret != 0 { throw SystemError(errNo: Int32(errno)) }
        return FileMetadata(stat: st, path: Path("/proc/self/fd/\(fd)"))
    }
    
    public static func fstat(fd: FileDescriptor) throws -> FileMetadata {
        return try fstat(fd: fd.rawValue)
    }
    
    public static func fstatat(dirfd: Int32, path: String, flags: Int32) throws -> FileMetadata {
        var st = Glibc.stat()
        
        let ret = path.withCString { p in
            return Syscall._execute_secure(
                sys_no: 262,
                ptr1: UnsafeRawPointer(bitPattern: Int(dirfd)),
                ptr2: UnsafeRawPointer(p),
                ptr3: UnsafeRawPointer(withUnsafeMutablePointer(to: &st) { $0 }),
                ptr4: UnsafeRawPointer(bitPattern: Int(flags))
            )
        }
        
        if ret != 0 { throw SystemError(errNo: Int32(errno)) }
        return FileMetadata(stat: st, path: Path(path))
    }
}
