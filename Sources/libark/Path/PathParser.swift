public struct PathParser {
    public static func parse(_ path: String) -> [PathComponent] {
        var components: [PathComponent] = []
        var isAbsolute = false
        
        if path.hasPrefix("/") {
            isAbsolute = true
            components.append(.root)
        }
        
        let parts = path.split(separator: "/")
        
        for part in parts {
            let str = String(part)
            if str.isEmpty { continue }
            
            if str == "." {
                components.append(.current)
            } else if str == ".." {
                components.append(.parent)
            } else {
                components.append(.name(str))
            }
        }
        
        // If it was just "/", ensure that is represented correctly
        if isAbsolute && components.count == 1 && components[0] == .root {
            return [.root]
        }
        
        // If it was empty or just ".", return current unless it's absolute
        if components.isEmpty && !isAbsolute {
            components.append(.current)
        }
        
        return components
    }
}
