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

#if canImport(Glibc)
import Glibc
typealias CStat = Glibc.stat
typealias CTm = Glibc.tm
typealias CTermios = Glibc.termios

@inlinable
func platform_mkdir(_ path: UnsafePointer<CChar>, _ mode: mode_t) -> Int32 {
    Glibc.mkdir(path, mode)
}

@inlinable
func platform_rmdir(_ path: UnsafePointer<CChar>) -> Int32 {
    Glibc.rmdir(path)
}

@inlinable
func platform_unlink(_ path: UnsafePointer<CChar>) -> Int32 {
    Glibc.unlink(path)
}

@inlinable
func platform_rename(_ oldPath: UnsafePointer<CChar>, _ newPath: UnsafePointer<CChar>) -> Int32 {
    Glibc.rename(oldPath, newPath)
}

#elseif canImport(Musl)
import Musl
typealias CStat = Musl.stat
typealias CTm = Musl.tm
typealias CTermios = Musl.termios

@inlinable
func platform_mkdir(_ path: UnsafePointer<CChar>, _ mode: mode_t) -> Int32 {
    Musl.mkdir(path, mode)
}

@inlinable
func platform_rmdir(_ path: UnsafePointer<CChar>) -> Int32 {
    Musl.rmdir(path)
}

@inlinable
func platform_unlink(_ path: UnsafePointer<CChar>) -> Int32 {
    Musl.unlink(path)
}

@inlinable
func platform_rename(_ oldPath: UnsafePointer<CChar>, _ newPath: UnsafePointer<CChar>) -> Int32 {
    Musl.rename(oldPath, newPath)
}

#elseif canImport(Darwin)
import Darwin
typealias CStat = Darwin.stat
typealias CTm = Darwin.tm
typealias CTermios = Darwin.termios

@inlinable
func platform_mkdir(_ path: UnsafePointer<CChar>, _ mode: mode_t) -> Int32 {
    Darwin.mkdir(path, mode)
}

@inlinable
func platform_rmdir(_ path: UnsafePointer<CChar>) -> Int32 {
    Darwin.rmdir(path)
}

@inlinable
func platform_unlink(_ path: UnsafePointer<CChar>) -> Int32 {
    Darwin.unlink(path)
}

@inlinable
func platform_rename(_ oldPath: UnsafePointer<CChar>, _ newPath: UnsafePointer<CChar>) -> Int32 {
    Darwin.rename(oldPath, newPath)
}
#endif

#if canImport(Darwin)
/// In the Apple Darwin SDK (`<sys/types.h>`), device number macros are defined as:
/// ```c
/// #define major(x)        ((int32_t)(((u_int32_t)(x) >> 24) & 0xff))
/// #define minor(x)        ((int32_t)((x) & 0xffffff))
/// #define makedev(x, y)   ((dev_t)(((x) << 24) | (y)))
/// ```
/// Because Swift's Clang importer does not import C function-like preprocessor macros,
/// these inline functions provide the exact platform-defined equivalent.
@inline(__always)
func platform_major(_ dev: dev_t) -> Int {
    return Int((UInt32(bitPattern: dev) >> 24) & 0xff)
}

@inline(__always)
func platform_minor(_ dev: dev_t) -> Int {
    return Int(UInt32(bitPattern: dev) & 0xffffff)
}
#elseif canImport(Glibc) || canImport(Musl)
/// In Linux (`<sys/sysmacros.h>`), device number macros are defined via `gnu_dev_major` / `gnu_dev_minor`:
/// ```c
/// #define major(dev) gnu_dev_major (dev)
/// #define minor(dev) gnu_dev_minor (dev)
/// ```
/// where:
///   gnu_dev_major(dev) = ((dev >> 8) & 0xfff) | ((dev >> 32) & ~0xfff)
///   gnu_dev_minor(dev) = (dev & 0xff) | ((dev >> 12) & ~0xff)
@inline(__always)
func platform_major(_ dev: dev_t) -> Int {
    let rdev = UInt64(dev)
    return Int((rdev >> 8) & 0xfff) | Int((rdev >> 32) & ~0xfff)
}

@inline(__always)
func platform_minor(_ dev: dev_t) -> Int {
    let rdev = UInt64(dev)
    return Int(rdev & 0xff) | Int((rdev >> 12) & ~0xff)
}
#endif

extension CStat {
    var platformAccessTime: timespec {
        #if canImport(Darwin)
        return self.st_atimespec
        #elseif canImport(Glibc) || canImport(Musl)
        return self.st_atim
        #endif
    }

    var platformModificationTime: timespec {
        #if canImport(Darwin)
        return self.st_mtimespec
        #elseif canImport(Glibc) || canImport(Musl)
        return self.st_mtim
        #endif
    }

    var platformChangeTime: timespec {
        #if canImport(Darwin)
        return self.st_ctimespec
        #elseif canImport(Glibc) || canImport(Musl)
        return self.st_ctim
        #endif
    }

    var platformBirthTime: timespec? {
        #if canImport(Darwin)
        return self.st_birthtimespec
        #elseif canImport(Glibc) || canImport(Musl)
        return nil
        #endif
    }

    var platformMajor: Int {
        return platform_major(self.st_rdev)
    }

    var platformMinor: Int {
        return platform_minor(self.st_rdev)
    }
}

