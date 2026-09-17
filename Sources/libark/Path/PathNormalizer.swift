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
