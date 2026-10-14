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

/// A single lexical component of a path.
///
/// `PathComponent` represents syntactic tokens within a path string without querying
/// or accessing the filesystem:
/// - `.root`: The leading directory separator (`/`) in an absolute path.
/// - `.current`: A reference to the current working directory (`.`).
/// - `.parent`: A reference to the parent directory (`..`).
/// - `.name(String)`: A named file or directory segment (e.g. `foo`, `bar.txt`).
public enum PathComponent: Equatable, Hashable, CustomStringConvertible, Comparable {
    case root
    case current
    case parent
    case name(String)
    
    /// The string representation of this path component.
    public var stringValue: String {
        switch self {
        case .root: return "/"
        case .current: return "."
        case .parent: return ".."
        case .name(let str): return str
        }
    }
    
    public var description: String {
        return stringValue
    }
    
    /// Strict total ordering on path components categorized by structural role:
    /// `.root` < `.current` < `.parent` < `.name(l) < .name(r)`
    ///
    /// Note: This orders components by structural category rather than raw ASCII string values (e.g. `.` vs `/`).
    /// Within named components (`.name`), standard lexicographical string comparison applies.
    public static func < (lhs: PathComponent, rhs: PathComponent) -> Bool {
        switch (lhs, rhs) {
        case (.root, .root), (.current, .current), (.parent, .parent):
            return false
        case (.name(let l), .name(let r)):
            return l < r
        case (.root, _):
            return true
        case (_, .root):
            return false
        case (.current, _):
            return true
        case (_, .current):
            return false
        case (.parent, _):
            return true
        case (_, .parent):
            return false
        }
    }
}

