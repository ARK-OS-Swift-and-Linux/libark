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
