import Glibc

public struct FileDescriptor: RawRepresentable, Equatable, Hashable {
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    // MARK: - Open
    public static func open(path: Path, flags: Int32, mode: mode_t = 0) throws -> FileDescriptor {
        let fd = path._with_unsafe_c_string { p in
            return Syscall._execute_secure(sys_no: 2, ptr1: UnsafeRawPointer(p), ptr2: UnsafeRawPointer(bitPattern: Int(flags)), ptr3: UnsafeRawPointer(bitPattern: Int(mode)))
        }
        if fd < 0 {
            throw SystemError(errNo: Int32(errno))
        }
        return FileDescriptor(rawValue: Int32(fd))
    }
    
    // MARK: - Close
    public func close() throws {
        let ret = Syscall._execute_secure(sys_no: 3, ptr1: UnsafeRawPointer(bitPattern: Int(rawValue)))
        if ret < 0 {
            throw SystemError(errNo: Int32(errno))
        }
    }
    
    // MARK: - I/O
    public func read(into buffer: UnsafeMutableRawBufferPointer) throws -> Int {
        guard let base = buffer.baseAddress else { return 0 }
        let ret = Syscall._execute_secure(sys_no: 0, ptr1: UnsafeRawPointer(bitPattern: Int(rawValue)), ptr2: UnsafeRawPointer(base), ptr3: UnsafeRawPointer(bitPattern: buffer.count))
        if ret < 0 {
            throw SystemError(errNo: Int32(errno))
        }
        return ret
    }
    
    public func write(from buffer: UnsafeRawBufferPointer) throws -> Int {
        guard let base = buffer.baseAddress else { return 0 }
        let ret = Syscall._execute_secure(sys_no: 1, ptr1: UnsafeRawPointer(bitPattern: Int(rawValue)), ptr2: base, ptr3: UnsafeRawPointer(bitPattern: buffer.count))
        if ret < 0 {
            throw SystemError(errNo: Int32(errno))
        }
        return ret
    }
    
    public func pread(into buffer: UnsafeMutableRawBufferPointer, offset: off_t) throws -> Int {
        guard let base = buffer.baseAddress else { return 0 }
        let ret = Syscall._execute_secure(sys_no: 17, ptr1: UnsafeRawPointer(bitPattern: Int(rawValue)), ptr2: UnsafeRawPointer(base), ptr3: UnsafeRawPointer(bitPattern: buffer.count), ptr4: UnsafeRawPointer(bitPattern: Int(offset)))
        if ret < 0 {
            throw SystemError(errNo: Int32(errno))
        }
        return ret
    }
    
    public func pwrite(from buffer: UnsafeRawBufferPointer, offset: off_t) throws -> Int {
        guard let base = buffer.baseAddress else { return 0 }
        let ret = Syscall._execute_secure(sys_no: 18, ptr1: UnsafeRawPointer(bitPattern: Int(rawValue)), ptr2: base, ptr3: UnsafeRawPointer(bitPattern: buffer.count), ptr4: UnsafeRawPointer(bitPattern: Int(offset)))
        if ret < 0 {
            throw SystemError(errNo: Int32(errno))
        }
        return ret
    }
    
    // MARK: - File Control
    public func seek(offset: off_t, whence: Int32) throws -> off_t {
        let ret = Syscall._execute_secure(sys_no: 8, ptr1: UnsafeRawPointer(bitPattern: Int(rawValue)), ptr2: UnsafeRawPointer(bitPattern: Int(offset)), ptr3: UnsafeRawPointer(bitPattern: Int(whence)))
        if ret < 0 {
            throw SystemError(errNo: Int32(errno))
        }
        return off_t(ret)
    }
    
    public func sync() throws {
        let ret = Syscall._execute_secure(sys_no: 74, ptr1: UnsafeRawPointer(bitPattern: Int(rawValue)))
        if ret < 0 {
            throw SystemError(errNo: Int32(errno))
        }
    }
    
    public func chmod(mode: Permissions) throws {
        let ret = Syscall._execute_secure(sys_no: 91, ptr1: UnsafeRawPointer(bitPattern: Int(rawValue)), ptr2: UnsafeRawPointer(bitPattern: Int(mode.octalValue)))
        if ret < 0 {
            throw SystemError(errNo: Int32(errno))
        }
    }
    
    public func chown(uid: uid_t, gid: gid_t) throws {
        let ret = Syscall._execute_secure(sys_no: 93, ptr1: UnsafeRawPointer(bitPattern: Int(rawValue)), ptr2: UnsafeRawPointer(bitPattern: Int(uid)), ptr3: UnsafeRawPointer(bitPattern: Int(gid)))
        if ret < 0 {
            throw SystemError(errNo: Int32(errno))
        }
    }
    
    // MARK: - Metadata
    public func stat() throws -> FileMetadata {
        return try FileMetadata.fstat(fd: self)
    }
}
