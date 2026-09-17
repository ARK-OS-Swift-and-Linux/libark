// Copyright 2026 Aarav Ravindra Kharade
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
