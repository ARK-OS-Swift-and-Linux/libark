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
