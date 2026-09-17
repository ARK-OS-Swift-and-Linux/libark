public enum PathComponent: Equatable {
    case root
    case current
    case parent
    case name(String)
    
    public var stringValue: String {
        switch self {
        case .root: return "/"
        case .current: return "."
        case .parent: return ".."
        case .name(let str): return str
        }
    }
}
