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

public struct Expansion {
    public static func expandTilde(in token: String, environment: [String: String]) -> String {
        if token.hasPrefix("~") {
            let home = environment["HOME"] ?? "/home/aarav"
            if token == "~" {
                return home
            } else if token.hasPrefix("~/") {
                return home + String(token.dropFirst())
            }
        }
        return token
    }

    public static func expandVariables(in token: String, environment: [String: String]) -> String {
        var expanded = token
        for (key, value) in environment {
            expanded = expanded.replacingOccurrences(of: "$\(key)", with: value)
            expanded = expanded.replacingOccurrences(of: "${\(key)}", with: value)
        }
        return expanded
    }

    public static func expandBraces(in tokens: [String]) -> [String] {
        var result: [String] = []
        for token in tokens {
            if let start = token.firstIndex(of: "{"), let end = token.lastIndex(of: "}") {
                let prefix = String(token[..<start])
                let suffix = String(token[token.index(after: end)...])
                let inside = String(token[token.index(after: start)..<end])
                
                if inside.contains("..") {
                    let bounds = inside.components(separatedBy: "..")
                    if bounds.count == 2, let lower = Int(bounds[0]), let upper = Int(bounds[1]) {
                        let step = lower <= upper ? 1 : -1
                        for i in stride(from: lower, through: upper, by: step) {
                            result.append("\(prefix)\(i)\(suffix)")
                        }
                    } else {
                        result.append(token)
                    }
                } else if inside.contains(",") {
                    let items = inside.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
                    for item in items {
                        result.append("\(prefix)\(item)\(suffix)")
                    }
                } else {
                    result.append(token)
                }
            } else {
                result.append(token)
            }
        }
        // Run recursively if there are still braces
        if result != tokens && result.contains(where: { $0.contains("{") }) {
            return expandBraces(in: result)
        }
        return result
    }
}
