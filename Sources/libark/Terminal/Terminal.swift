import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A representation of a terminal interface connected to a file descriptor.
public struct Terminal: Sendable {
    /// The raw POSIX file descriptor backing this terminal (e.g. STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO).
    public let fd: Int32

    /// Initializes a `Terminal` linked to a specific file descriptor.
    public init(fd: Int32) {
        self.fd = fd
    }
    
    /// Standard output stream (STDOUT_FILENO = 1).
    public static let stdout = Terminal(fd: STDOUT_FILENO)
    
    /// Standard error stream (STDERR_FILENO = 2).
    public static let stderr = Terminal(fd: STDERR_FILENO)
    
    /// Standard input stream (STDIN_FILENO = 0).
    public static let stdin = Terminal(fd: STDIN_FILENO)

    /// Returns `true` if the underlying file descriptor is connected to a TTY device.
    public var isTTY: Bool {
        var termios = Glibc.termios()
        // sys_ioctl (16) with TCGETS (0x5401 on x86_64 Linux)
        let ret = Syscall._execute_secure(sys_no: 16, ptr1: UnsafeRawPointer(bitPattern: Int(fd)), ptr2: UnsafeRawPointer(bitPattern: 0x5401), ptr3: UnsafeRawPointer(withUnsafeMutablePointer(to: &termios) { $0 }))
        return ret == 0
    }
    
    /// The width (columns) of the terminal. If the terminal width cannot be determined, returns a fallback value of 80.
    public var width: Int {
        var w = winsize()
        // sys_ioctl (16) with TIOCGWINSZ (0x5413 on x86_64 Linux)
        let ret = Syscall._execute_secure(sys_no: 16, ptr1: UnsafeRawPointer(bitPattern: Int(fd)), ptr2: UnsafeRawPointer(bitPattern: 0x5413), ptr3: UnsafeRawPointer(withUnsafeMutablePointer(to: &w) { $0 }))
        if ret == 0 {
            return Int(w.ws_col)
        }
        return 80 // Default fallback width
    }
    
    /// The height (rows) of the terminal. If the terminal height cannot be determined, returns a fallback value of 24.
    public var height: Int {
        var w = winsize()
        // sys_ioctl (16) with TIOCGWINSZ (0x5413 on x86_64 Linux)
        let ret = Syscall._execute_secure(sys_no: 16, ptr1: UnsafeRawPointer(bitPattern: Int(fd)), ptr2: UnsafeRawPointer(bitPattern: 0x5413), ptr3: UnsafeRawPointer(withUnsafeMutablePointer(to: &w) { $0 }))
        if ret == 0 {
            return Int(w.ws_row)
        }
        return 24 // Default fallback height
    }

    /// True if the terminal supports basic colors (always true for modern virtual terminals if it is a TTY, but can be customized).
    public var colors: Bool {
        return isTTY
    }
}
