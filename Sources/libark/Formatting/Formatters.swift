import Foundation

public struct FileTypeFormatter {
    public static func character(for type: FileType) -> Character {
        switch type {
        case .directory: return "d"
        case .symbolicLink: return "l"
        case .characterDevice: return "c"
        case .blockDevice: return "b"
        case .fifo: return "p"
        case .socket: return "s"
        case .regular, .unknown: return "-"
        }
    }
}

public struct PermissionFormatter {
    public static func format(metadata: FileMetadata) -> String {
        let typeChar = FileTypeFormatter.character(for: metadata.fileType)
        return "\(typeChar)\(metadata.permissions.stringRepresentation)"
    }
}

public struct OwnerFormatter {
    /// Translates a numeric User ID (UID) into its string representation.
    /// Future implementations will query `/etc/passwd` via `getpwuid` for username resolution.
    public static func format(uid: UInt32) -> String {
        return String(uid)
    }
    
    public static func format(gid: UInt32) -> String {
        return String(gid)
    }
}

public struct NameFormatter {
    public var classify: Bool
    
    public init(classify: Bool = false) {
        self.classify = classify
    }
    
    public func format(metadata: FileMetadata) -> String {
        let rawName = metadata.path.filename ?? metadata.path.string
        
        if classify {
            return rawName + classificationSuffix(for: metadata)
        }
        
        return rawName
    }
    
    private func classificationSuffix(for metadata: FileMetadata) -> String {
        switch metadata.fileType {
        case .directory:
            return "/"
        case .symbolicLink:
            return "@"
        case .socket:
            return "="
        case .fifo:
            return "|"
        case .regular:
            if metadata.permissions.owner.execute ||
               metadata.permissions.group.execute ||
               metadata.permissions.other.execute {
                return "*"
            }
            return ""
        default:
            return ""
        }
    }
}
