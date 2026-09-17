import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

public struct PathResolver {
    public static func canonicalize(_ pathString: String) throws -> String {
        let resolved = realpath(pathString, nil)
        guard let resolvedPtr = resolved else {
            let error = String(cString: strerror(errno))
            throw NSError(domain: "PathResolver", code: Int(errno), userInfo: [NSLocalizedDescriptionKey: "Failed to canonicalize path '\(pathString)': \(error)"])
        }
        defer {
            free(resolvedPtr)
        }
        
        return String(cString: resolvedPtr)
    }
}
