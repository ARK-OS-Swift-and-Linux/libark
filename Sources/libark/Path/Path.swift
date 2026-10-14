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

#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A representation of a filesystem path providing purely lexical manipulation.
///
/// `Path` manages path syntax independent of the underlying filesystem state.
/// Normalization, joining, component extraction, and relative navigation operate
/// on lexical tokens without invoking POSIX syscalls or resolving symlinks.
public struct Path: Equatable, Hashable, CustomStringConvertible, Comparable, ExpressibleByStringLiteral {
    /// The ordered sequence of lexical components forming this path.
    public let components: [PathComponent]
    
    /// Indicates whether the original path representation included a trailing slash delimiter,
    /// indicating an explicit directory intent on non-root paths.
    public let hasTrailingSlash: Bool
    
    /// Initializes a path by parsing a string representation.
    ///
    /// - Parameter string: The path string to parse.
    public init(_ string: String) {
        let isRootOnly = string.allSatisfy { $0 == "/" }
        self.hasTrailingSlash = string.hasSuffix("/") && !isRootOnly
        self.components = PathParser.parse(string)
    }
    
    /// Initializes a path directly from an array of components.
    ///
    /// - Parameters:
    ///   - components: The sequence of path components.
    ///   - hasTrailingSlash: Whether to preserve a trailing directory delimiter. Defaults to `false`.
    public init(components: [PathComponent], hasTrailingSlash: Bool = false) {
        self.components = components.isEmpty ? [.current] : components
        self.hasTrailingSlash = hasTrailingSlash
    }
    
    /// Initializes a path from a string literal.
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    /// Indicates whether the path begins at the filesystem root (`/`).
    public var isAbsolute: Bool {
        return components.first == .root
    }
    
    /// Indicates whether the path is relative to the current directory.
    public var isRelative: Bool {
        return !isAbsolute
    }
    
    /// Returns the string representation of the path.
    public var string: String {
        if components.isEmpty { return "" }
        if components.count == 1 && components[0] == .root { return "/" }
        
        var result = ""
        for (i, comp) in components.enumerated() {
            if comp == .root {
                result += "/"
            } else {
                result += comp.stringValue
                // Append slash if it's not the last component and we aren't following root
                if i < components.count - 1 && comp != .root {
                    result += "/"
                }
            }
        }
        if hasTrailingSlash && result != "/" && !result.hasSuffix("/") {
            result += "/"
        }
        return result
    }
    
    public var description: String { return string }
    
    /// Lexicographically compares two paths by their component sequences,
    /// establishing a strict weak ordering consistent with `Equatable`.
    ///
    /// Ordering semantics:
    /// - Paths are compared component-wise using `PathComponent`'s structural total order
    ///   (`.root < .current < .parent < .name(...)`), rather than raw ASCII string comparison.
    /// - Equal paths differing only by trailing slash (e.g. `/var/log/` vs `/var/log`)
    ///   evaluate to neither path being less than the other, strictly satisfying `!(a < b) && !(b < a) <=> a == b`.
    /// - Lexicographical prefix rule: if all shared prefix components are identical, the path with fewer components is smaller.
    public static func < (lhs: Path, rhs: Path) -> Bool {
        let minCount = min(lhs.components.count, rhs.components.count)
        for i in 0..<minCount {
            let l = lhs.components[i]
            let r = rhs.components[i]
            if l != r {
                return l < r
            }
        }
        return lhs.components.count < rhs.components.count
    }
    
    /// Returns the parent directory path, or `nil` if this path is the root directory.
    ///
    /// Lexical parent rules:
    /// - Root (`/`) has no parent, returning `nil`.
    /// - Current directory (`.`) has parent `.`.
    /// - Relative parent (`..`) has parent `.`.
    /// - Multi-level relative parents (e.g. `../..`) return their parent prefix (`..`).
    /// - Ordinary paths return their enclosing directory prefix (e.g. `/var/log` -> `/var`, `a/b` -> `a`, `a` -> `.`).
    public var parent: Path? {
        let norm = self.normalize()
        if norm.components == [.root] { return nil }
        if norm.components == [.current] {
            return Path(components: [.current])
        }
        var newComponents = norm.components
        newComponents.removeLast()
        if newComponents.isEmpty {
            return Path(components: [.current])
        }
        return Path(components: newComponents)
    }
    
    // MARK: - Equatable & Hashable
    
    /// Two paths are considered equal if their lexical component sequences are identical,
    /// regardless of whether one path has an inspectable trailing directory delimiter.
    public static func == (lhs: Path, rhs: Path) -> Bool {
        return lhs.components == rhs.components
    }
    
    /// Hashes the path's component sequence consistently with `==`.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(components)
    }
    
    /// The leaf filename of the path, or `nil` if the path ends in root or is empty.
    public var filename: String? {
        guard let last = components.last else { return nil }
        if case .name(let str) = last {
            return str
        }
        return nil
    }
    
    /// The file extension excluding the leading dot, or `nil` if no extension is present.
    ///
    /// Rules:
    /// - Dotfiles without a secondary extension (e.g. `.bashrc`, `..bashrc`) return `nil`.
    /// - Multi-dot files (e.g. `archive.tar.gz`, `.tar.gz`) yield the final extension (`gz`).
    /// - Files without an extension (e.g. `Makefile`) return `nil`.
    /// - Special paths (`.`, `..`, `/`) return `nil`.
    public var `extension`: String? {
        guard let fname = filename else { return nil }
        // Find the first character that is not a dot to skip leading dotfile prefixes
        guard let nonDotIndex = fname.firstIndex(where: { $0 != "." }) else {
            return nil
        }
        guard let lastDot = fname.lastIndex(of: ".") else { return nil }
        // If the only dots are leading dots, there is no extension
        if lastDot <= nonDotIndex {
            return nil
        }
        let ext = fname[fname.index(after: lastDot)...]
        guard !ext.isEmpty else { return nil }
        return String(ext)
    }
    
    /// The base filename without its final file extension, or `nil` if no filename exists.
    ///
    /// Examples:
    /// - `syslog.1.gz` -> `syslog.1`
    /// - `archive.tar.gz` -> `archive.tar`
    /// - `.bashrc` -> `.bashrc`
    /// - `..bashrc` -> `..bashrc`
    /// - `Makefile` -> `Makefile`
    /// - `file.` -> `file.`
    public var stem: String? {
        guard let fname = filename else { return nil }
        guard let nonDotIndex = fname.firstIndex(where: { $0 != "." }) else {
            return fname
        }
        guard let lastDot = fname.lastIndex(of: ".") else {
            return fname
        }
        if lastDot <= nonDotIndex {
            return fname
        }
        // If the dot is at the very end with no extension characters following,
        // the trailing dot remains part of the stem.
        if lastDot == fname.index(before: fname.endIndex) {
            return fname
        }
        let s = fname[..<lastDot]
        return String(s)
    }
    
    // MARK: - Capabilities
    
    /// Appends another path onto this path.
    ///
    /// If `other` is absolute, it completely replaces `self`.
    public func join(_ other: Path) -> Path {
        let joined = PathJoiner.join(self.components, other.components)
        let trailing = other.hasTrailingSlash
        return Path(components: joined, hasTrailingSlash: trailing)
    }
    
    /// Appends a raw string path onto this path.
    public func join(_ string: String) -> Path {
        return join(Path(string))
    }
    
    /// Operator overload for path concatenation.
    public static func / (lhs: Path, rhs: Path) -> Path {
        return lhs.join(rhs)
    }
    
    /// Operator overload for path and string concatenation.
    public static func / (lhs: Path, rhs: String) -> Path {
        return lhs.join(Path(rhs))
    }
    
    /// Returns a lexically normalized path.
    ///
    /// Strips trailing slashes by default unless `preserveTrailingSlash` is set to `true`.
    public func normalize(preserveTrailingSlash: Bool = false) -> Path {
        let normalizedComponents = PathNormalizer.normalize(self.components)
        let keepTrailing = preserveTrailingSlash && self.hasTrailingSlash && normalizedComponents != [.root]
        return Path(components: normalizedComponents, hasTrailingSlash: keepTrailing)
    }
    
    public func absolute(cwd: Path? = nil) -> Path {
        if isAbsolute { return self }
        
        let base: Path
        if let cwd = cwd {
            base = cwd
        } else {
            var buf = [CChar](repeating: 0, count: Int(PATH_MAX))
            if let ptr = getcwd(&buf, buf.count) {
                base = Path(String(cString: ptr))
            } else {
                base = Path(components: [.root]) // Fallback
            }
        }
        
        return base.join(self)
    }
    
    /// Resolves the path to an absolute, normalized string purely through lexical manipulation.
    /// Does NOT touch the filesystem or resolve symlinks.
    public func resolve(cwd: Path? = nil) -> Path {
        return self.absolute(cwd: cwd).normalize()
    }
    
    /// Canonicalizes the path by querying the POSIX filesystem to resolve all symlinks, `..`, and `.`.
    /// The path must exist.
    public func canonicalize() throws -> Path {
        let canonicalStr = try PathResolver.canonicalize(self.string)
        return Path(canonicalStr)
    }
    
    /// Returns a relative path from the given base path to this path.
    public func relative(to base: Path) -> Path {
        let resolvedBase = base.resolve().components
        let resolvedSelf = self.resolve().components
        
        var commonPrefixCount = 0
        let minCount = min(resolvedBase.count, resolvedSelf.count)
        
        for i in 0..<minCount {
            if resolvedBase[i] == resolvedSelf[i] {
                commonPrefixCount += 1
            } else {
                break
            }
        }
        
        var relativeComponents: [PathComponent] = []
        for i in commonPrefixCount..<resolvedBase.count {
            if resolvedBase[i] != .root { // Ignore if the only common prefix was root
                relativeComponents.append(.parent)
            }
        }
        
        for i in commonPrefixCount..<resolvedSelf.count {
            relativeComponents.append(resolvedSelf[i])
        }
        
        if relativeComponents.isEmpty {
            relativeComponents.append(.current)
        }
        
        return Path(components: relativeComponents)
    }
    
    // MARK: - Legacy / Filesystem compatibility
    
    public func _with_unsafe_c_string<R>(_ body: (UnsafePointer<CChar>) throws -> R) rethrows -> R {
        return try string.withCString(body)
    }
    
    public func exists() -> Bool {
        return _with_unsafe_c_string { p in
            var statbuf = stat()
            let s_ptr = withUnsafeMutablePointer(to: &statbuf) { $0 }
            let ret = Syscall._execute_secure(sys_no: 4, ptr1: UnsafeRawPointer(p), ptr2: UnsafeRawPointer(s_ptr))
            return ret == 0
        }
    }
    
    public func isDirectory() -> Bool {
        return _with_unsafe_c_string { p in
            var statbuf = stat()
            let s_ptr = withUnsafeMutablePointer(to: &statbuf) { $0 }
            if Syscall._execute_secure(sys_no: 4, ptr1: UnsafeRawPointer(p), ptr2: UnsafeRawPointer(s_ptr)) == 0 {
                return (statbuf.st_mode & S_IFMT) == S_IFDIR
            }
            return false
        }
    }
}
