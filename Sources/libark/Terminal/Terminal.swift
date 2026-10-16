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

import Foundation

#if canImport(Glibc)
import Glibc

func platform_terminal_isatty(fd: Int32) -> Bool {
    return Glibc.isatty(fd) != 0
}

func platform_terminal_winsize(fd: Int32, _ w: inout winsize) -> Int32 {
    return withUnsafeMutablePointer(to: &w) { wPtr in
        Glibc.ioctl(fd, UInt(TIOCGWINSZ), wPtr)
    }
}
#elseif canImport(Musl)
import Musl

func platform_terminal_isatty(fd: Int32) -> Bool {
    return Musl.isatty(fd) != 0
}

func platform_terminal_winsize(fd: Int32, _ w: inout winsize) -> Int32 {
    return withUnsafeMutablePointer(to: &w) { wPtr in
        Musl.ioctl(fd, UInt(TIOCGWINSZ), wPtr)
    }
}
#elseif canImport(Darwin)
import Darwin

func platform_terminal_isatty(fd: Int32) -> Bool {
    return Darwin.isatty(fd) != 0
}

func platform_terminal_winsize(fd: Int32, _ w: inout winsize) -> Int32 {
    return withUnsafeMutablePointer(to: &w) { wPtr in
        Darwin.ioctl(fd, UInt(TIOCGWINSZ), wPtr)
    }
}
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
        return platform_terminal_isatty(fd: fd)
    }
    
    /// The width (columns) of the terminal. If the terminal width cannot be determined, returns a fallback value of 80.
    public var width: Int {
        var w = winsize()
        if platform_terminal_winsize(fd: fd, &w) == 0 {
            return Int(w.ws_col)
        }
        return 80 // Default fallback width
    }
    
    /// The height (rows) of the terminal. If the terminal height cannot be determined, returns a fallback value of 24.
    public var height: Int {
        var w = winsize()
        if platform_terminal_winsize(fd: fd, &w) == 0 {
            return Int(w.ws_row)
        }
        return 24 // Default fallback height
    }

    /// True if the terminal supports basic colors (always true for modern virtual terminals if it is a TTY, but can be customized).
    public var colors: Bool {
        return isTTY
    }
}
