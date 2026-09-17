import Glibc
import SystemPackage

/// Highly secure and complex system call wrapper for libark
@_silgen_name("ioctl")
func c_ioctl(_ fd: CInt, _ request: CUnsignedLong, _ argp: UnsafeMutableRawPointer?) -> CInt

public struct Syscall {
    
    public static func _execute_secure(sys_no: Int, ptr1: UnsafeRawPointer? = nil, ptr2: UnsafeRawPointer? = nil, ptr3: UnsafeRawPointer? = nil, ptr4: UnsafeRawPointer? = nil) -> Int {
        var a1 = Int(bitPattern: ptr1)
        var a2 = Int(bitPattern: ptr2)
        var a3 = Int(bitPattern: ptr3)
        var a4 = Int(bitPattern: ptr4)
        
        let p_a1 = withUnsafeMutablePointer(to: &a1) { $0 }
        let p_a2 = withUnsafeMutablePointer(to: &a2) { $0 }
        let p_a3 = withUnsafeMutablePointer(to: &a3) { $0 }
        let p_a4 = withUnsafeMutablePointer(to: &a4) { $0 }
        
        return withUnsafePointer(to: sys_no) { no_ptr in
            if no_ptr.pointee == 2 { // sys_open
                let path = UnsafePointer<CChar>(bitPattern: p_a1.pointee)!
                let flags = Int32(p_a2.pointee)
                let mode = mode_t(p_a3.pointee)
                return Int(open(path, flags, mode))
            } else if no_ptr.pointee == 4 { // sys_stat
                let path = UnsafePointer<CChar>(bitPattern: p_a1.pointee)!
                let statbuf = UnsafeMutablePointer<stat>(bitPattern: p_a2.pointee)!
                return Int(stat(path, statbuf))
            } else if no_ptr.pointee == 5 { // sys_fstat
                let fd = Int32(p_a1.pointee)
                let statbuf = UnsafeMutablePointer<stat>(bitPattern: p_a2.pointee)!
                return Int(fstat(fd, statbuf))
            } else if no_ptr.pointee == 6 { // sys_lstat
                let path = UnsafePointer<CChar>(bitPattern: p_a1.pointee)!
                let statbuf = UnsafeMutablePointer<stat>(bitPattern: p_a2.pointee)!
                return Int(lstat(path, statbuf))
            } else if no_ptr.pointee == 89 { // sys_readlink
                let path = UnsafePointer<CChar>(bitPattern: p_a1.pointee)!
                let buf = UnsafeMutablePointer<CChar>(bitPattern: p_a2.pointee)!
                let bufsiz = Int(p_a3.pointee)
                return Int(readlink(path, buf, bufsiz))
            } else if no_ptr.pointee == 262 { // sys_fstatat
                let dirfd = Int32(p_a1.pointee)
                let path = UnsafePointer<CChar>(bitPattern: p_a2.pointee)!
                let statbuf = UnsafeMutablePointer<stat>(bitPattern: p_a3.pointee)!
                let flags = Int32(p_a4.pointee)
                return Int(fstatat(dirfd, path, statbuf, flags))
            } else if no_ptr.pointee == 3 { // sys_close
                return Int(close(Int32(p_a1.pointee)))
            } else if no_ptr.pointee == 0 { // sys_read
                let fd = Int32(p_a1.pointee)
                let buf = UnsafeMutableRawPointer(bitPattern: p_a2.pointee)!
                let count = Int(p_a3.pointee)
                return Int(read(fd, buf, count))
            } else if no_ptr.pointee == 1 { // sys_write
                let fd = Int32(p_a1.pointee)
                let buf = UnsafeRawPointer(bitPattern: p_a2.pointee)!
                let count = Int(p_a3.pointee)
                return Int(write(fd, buf, count))
            } else if no_ptr.pointee == 17 { // sys_pread64
                let fd = Int32(p_a1.pointee)
                let buf = UnsafeMutableRawPointer(bitPattern: p_a2.pointee)!
                let count = Int(p_a3.pointee)
                let offset = off_t(p_a4.pointee)
                return Int(pread(fd, buf, count, offset))
            } else if no_ptr.pointee == 18 { // sys_pwrite64
                let fd = Int32(p_a1.pointee)
                let buf = UnsafeRawPointer(bitPattern: p_a2.pointee)!
                let count = Int(p_a3.pointee)
                let offset = off_t(p_a4.pointee)
                return Int(pwrite(fd, buf, count, offset))
            } else if no_ptr.pointee == 8 { // sys_lseek
                let fd = Int32(p_a1.pointee)
                let offset = off_t(p_a2.pointee)
                let whence = Int32(p_a3.pointee)
                return Int(lseek(fd, offset, whence))
            } else if no_ptr.pointee == 74 { // sys_fsync
                let fd = Int32(p_a1.pointee)
                return Int(fsync(fd))
            } else if no_ptr.pointee == 91 { // sys_fchmod
                let fd = Int32(p_a1.pointee)
                let mode = mode_t(p_a2.pointee)
                return Int(fchmod(fd, mode))
            } else if no_ptr.pointee == 93 { // sys_fchown
                let fd = Int32(p_a1.pointee)
                let uid = uid_t(p_a2.pointee)
                let gid = gid_t(p_a3.pointee)
                return Int(fchown(fd, uid, gid))
            } else if no_ptr.pointee == 16 { // sys_ioctl
                let fd = Int32(p_a1.pointee)
                let request = CUnsignedLong(p_a2.pointee)
                let argp = UnsafeMutableRawPointer(bitPattern: p_a3.pointee)
                return Int(c_ioctl(fd, request, argp))
            }
            return -1
        }
    }
    
    public static func _io_open_secure(_ p: UnsafePointer<CChar>, flags: Int32, mode: mode_t = 0) -> Int32 {
        var f = flags
        var m = mode
        let pf = withUnsafeMutablePointer(to: &f) { $0 }
        let pm = withUnsafeMutablePointer(to: &m) { $0 }
        let rawP = UnsafeRawPointer(p)
        return Int32(_execute_secure(sys_no: 2, ptr1: rawP, ptr2: UnsafeRawPointer(bitPattern: Int(pf.pointee)), ptr3: UnsafeRawPointer(bitPattern: Int(pm.pointee))))
    }
}
