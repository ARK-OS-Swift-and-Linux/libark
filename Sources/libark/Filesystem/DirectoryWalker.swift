public class DirectoryWalker: Sequence, IteratorProtocol {
    private var stack: [Directory] = []
    public let followSymlinks: Bool
    
    public init(root: Path, followSymlinks: Bool = false) {
        self.followSymlinks = followSymlinks
        if let dir = try? Directory.open(path: root) {
            stack.append(dir)
        }
    }
    
    public func next() -> DirectoryEntry? {
        while !stack.isEmpty {
            let currentDir = stack.last!
            
            if let entry = try? currentDir.read() {
                if entry.name == "." || entry.name == ".." {
                    continue
                }
                
                if entry.type == .directory {
                    if let newDir = try? Directory.open(path: entry.path) {
                        stack.append(newDir)
                    }
                } else if entry.type == .symbolicLink && followSymlinks {
                    if let meta = try? FileMetadata.stat(path: entry.path, resolve: .follow), meta.fileType == .directory {
                        if let newDir = try? Directory.open(path: entry.path) {
                            stack.append(newDir)
                        }
                    }
                }
                
                return entry
            } else {
                stack.removeLast()
            }
        }
        return nil
    }
}
