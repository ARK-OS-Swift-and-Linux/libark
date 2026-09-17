#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Defines whether file operations should follow symlinks or target the symlink itself.
public enum SymlinkResolution {
    /// Follow all symlinks, including the final component (equivalent to `stat`).
    case follow
    /// Do not follow the final symlink component (equivalent to `lstat`).
    case noFollow
}

/// A highly secure reader for extracting symbolic link targets using direct syscalls.
public struct SymlinkReader {
    /// Safely reads a symbolic link target without relying on vulnerable libc string functions.
    /// - Parameter path: The path to the symbolic link.
    /// - Returns: The target path as a `String`, or `nil` if it fails or is not a symlink.
    public static func readlink(path: Path) -> String? {
        var buf = [UInt8](repeating: 0, count: 4096)
        let bufsiz = buf.count - 1
        
        let len = path._with_unsafe_c_string { p in
            return buf.withUnsafeMutableBufferPointer { b in
                // sys_readlink (89)
                return Syscall._execute_secure(
                    sys_no: 89,
                    ptr1: UnsafeRawPointer(p),
                    ptr2: UnsafeRawPointer(b.baseAddress!),
                    ptr3: UnsafeRawPointer(bitPattern: bufsiz)
                )
            }
        }
        
        guard len > 0 else { return nil }
        
        // Decode directly from the buffer up to `len` bytes to prevent buffer overflow vulnerabilities
        // and to avoid the deprecated `String(cString:)` initializer.
        return String(decoding: buf.prefix(upTo: len), as: UTF8.self)
    }
    
    /// Safely reads a symbolic link target relative to a directory file descriptor.
    /// - Parameters:
    ///   - dirfd: The directory file descriptor.
    ///   - path: The relative path.
    /// - Returns: The target path as a `String`, or `nil`.
    public static func readlinkat(dirfd: Int32, path: String) -> String? {
        var buf = [UInt8](repeating: 0, count: 4096)
        let bufsiz = buf.count - 1
        
        let len = path.withCString { p in
            return buf.withUnsafeMutableBufferPointer { b in
                // sys_readlinkat (267)
                return Syscall._execute_secure(
                    sys_no: 267,
                    ptr1: UnsafeRawPointer(bitPattern: Int(dirfd)),
                    ptr2: UnsafeRawPointer(p),
                    ptr3: UnsafeRawPointer(b.baseAddress!),
                    ptr4: UnsafeRawPointer(bitPattern: bufsiz)
                )
            }
        }
        
        guard len > 0 else { return nil }
        return String(decoding: buf.prefix(upTo: len), as: UTF8.self)
    }
}
