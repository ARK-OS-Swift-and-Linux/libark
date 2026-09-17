public struct PathNormalizer {
    public static func normalize(_ components: [PathComponent]) -> [PathComponent] {
        var normalized: [PathComponent] = []
        
        for component in components {
            switch component {
            case .root:
                normalized.removeAll()
                normalized.append(.root)
            case .current:
                // Ignore '.' unless the path is completely empty, 
                // in which case it represents the current directory.
                if normalized.isEmpty {
                    normalized.append(.current)
                }
            case .parent:
                if let last = normalized.last {
                    switch last {
                    case .root:
                        // /.. remains /
                        break
                    case .parent:
                        // .. followed by .. -> ../..
                        normalized.append(.parent)
                    case .current:
                        // . followed by .. -> ..
                        normalized.removeLast()
                        normalized.append(.parent)
                    case .name:
                        // name followed by .. -> cancel out
                        normalized.removeLast()
                    }
                } else {
                    // Start of relative path
                    normalized.append(.parent)
                }
            case .name(let name):
                // If the only component is .current, remove it before adding the name
                if normalized.count == 1 && normalized[0] == .current {
                    normalized.removeLast()
                }
                normalized.append(.name(name))
            }
        }
        
        if normalized.isEmpty {
            normalized.append(.current)
        }
        
        return normalized
    }
}
