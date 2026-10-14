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
@_exported import Glibc
public typealias CStat = Glibc.stat
public typealias CTm = Glibc.tm
public typealias CTermios = Glibc.termios

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
@_exported import Musl
public typealias CStat = Musl.stat
public typealias CTm = Musl.tm
public typealias CTermios = Musl.termios

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
@_exported import Darwin
public typealias CStat = Darwin.stat
public typealias CTm = Darwin.tm
public typealias CTermios = Darwin.termios

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
