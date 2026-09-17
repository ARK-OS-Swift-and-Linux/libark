public struct PathJoiner {
    public static func join(_ lhs: [PathComponent], _ rhs: [PathComponent]) -> [PathComponent] {
        if rhs.isEmpty {
            return lhs
        }
        
        // If RHS is absolute, it replaces LHS entirely.
        if rhs[0] == .root {
            return rhs
        }
        
        var result = lhs
        
        // Remove trailing `.current` from LHS if we are going to append to it
        if result.count == 1 && result[0] == .current {
            result.removeLast()
        }
        
        for component in rhs {
            // Skip `.current` in RHS unless LHS is empty
            if component == .current && !result.isEmpty {
                continue
            }
            result.append(component)
        }
        
        if result.isEmpty {
            result.append(.current)
        }
        
        return result
    }
}
