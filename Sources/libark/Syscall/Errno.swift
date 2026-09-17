import Glibc

public enum SystemError: Error, CustomStringConvertible, Equatable {
    case permissionDenied
    case noSuchFile
    case notDirectory
    case alreadyExists
    case notEmpty
    case invalidArgument
    case interrupted
    case busy
    case unknown(Int32)
    
    public init(errNo: Int32) {
        switch errNo {
        case EACCES, EPERM:
            self = .permissionDenied
        case ENOENT:
            self = .noSuchFile
        case ENOTDIR:
            self = .notDirectory
        case EEXIST:
            self = .alreadyExists
        case ENOTEMPTY:
            self = .notEmpty
        case EINVAL:
            self = .invalidArgument
        case EINTR:
            self = .interrupted
        case EBUSY:
            self = .busy
        default:
            self = .unknown(errNo)
        }
    }
    
    public var errNo: Int32 {
        switch self {
        case .permissionDenied: return EACCES
        case .noSuchFile: return ENOENT
        case .notDirectory: return ENOTDIR
        case .alreadyExists: return EEXIST
        case .notEmpty: return ENOTEMPTY
        case .invalidArgument: return EINVAL
        case .interrupted: return EINTR
        case .busy: return EBUSY
        case .unknown(let code): return code
        }
    }
    
    public var description: String {
        return String(cString: strerror(errNo))
    }
}
