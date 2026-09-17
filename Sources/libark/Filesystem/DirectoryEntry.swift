import Glibc

public struct DirectoryEntry {
    public let name: String
    public let path: Path
    public let type: FileType
    
    public init(name: String, path: Path, type: FileType) {
        self.name = name
        self.path = path
        self.type = type
    }
}

extension FileType {
    public init(d_type: UInt8) {
        switch Int(d_type) {
        case Int(DT_REG): self = .regular
        case Int(DT_DIR): self = .directory
        case Int(DT_LNK): self = .symbolicLink
        case Int(DT_CHR): self = .characterDevice
        case Int(DT_BLK): self = .blockDevice
        case Int(DT_FIFO): self = .fifo
        case Int(DT_SOCK): self = .socket
        default: self = .unknown
        }
    }
}
