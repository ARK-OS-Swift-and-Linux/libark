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
