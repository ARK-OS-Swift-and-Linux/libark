import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

public struct Path: Equatable, CustomStringConvertible {
    public let components: [PathComponent]
    
    public init(_ string: String) {
        self.components = PathParser.parse(string)
    }
    
    public init(components: [PathComponent]) {
        self.components = components.isEmpty ? [.current] : components
    }
    
    public var isAbsolute: Bool {
        return components.first == .root
    }
    
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
        return result
    }
    
    public var description: String { return string }
    
    public var parent: Path? {
        if components == [.root] { return nil }
        var newComponents = components
        newComponents.removeLast()
        if newComponents.isEmpty {
            return Path(components: [.current])
        }
        return Path(components: newComponents)
    }
    
    public var filename: String? {
        guard let last = components.last else { return nil }
        if case .name(let str) = last {
            return str
        }
        return nil
    }
    
    public var `extension`: String? {
        guard let fname = filename else { return nil }
        guard let lastDot = fname.lastIndex(of: ".") else { return nil }
        if lastDot == fname.startIndex { return nil } // .hidden files don't have extensions
        let ext = fname[fname.index(after: lastDot)...]
        return String(ext)
    }
    
    public var stem: String? {
        guard let fname = filename else { return nil }
        guard let lastDot = fname.lastIndex(of: ".") else { return fname }
        if lastDot == fname.startIndex { return fname }
        let s = fname[..<lastDot]
        return String(s)
    }
    
    // MARK: - Capabilities
    
    public func join(_ other: Path) -> Path {
        let joined = PathJoiner.join(self.components, other.components)
        return Path(components: joined)
    }
    
    public func join(_ string: String) -> Path {
        return join(Path(string))
    }
    
    public func normalize() -> Path {
        let normalized = PathNormalizer.normalize(self.components)
        return Path(components: normalized)
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
        for _ in commonPrefixCount..<resolvedBase.count {
            if resolvedBase[commonPrefixCount] != .root { // Ignore if the only common prefix was root
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
