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

public enum SortCriteria {
    case name
    case size
    case mtime
    case atime
    case ctime
    case `extension`
    case version
    case none
}

public struct SortEngine {
    public var criteria: [SortCriteria]
    public var reverse: Bool

    public init(criteria: [SortCriteria] = [.name], reverse: Bool = false) {
        self.criteria = criteria
        self.reverse = reverse
    }

    public func sort(_ files: [FileMetadata]) -> [FileMetadata] {
        if criteria.contains(.none) {
            return reverse ? files.reversed() : files
        }

        var sortedFiles = files

        sortedFiles.sort { a, b in
            for criterion in criteria {
                let result = compare(a, b, by: criterion)
                if result != .orderedSame {
                    return result == .orderedAscending
                }
            }
            /// Maintains stable sort if all specified criteria evaluate to .orderedSame.
            return false
        }

        if reverse {
            sortedFiles.reverse()
        }

        return sortedFiles
    }

    private func compare(_ a: FileMetadata, _ b: FileMetadata, by criterion: SortCriteria) -> ComparisonResult {
        let aName = a.path.filename ?? a.path.string
        let bName = b.path.filename ?? b.path.string

        switch criterion {
        case .name:
            if aName.lowercased() == bName.lowercased() {
                return .orderedSame
            }
            return aName.lowercased() < bName.lowercased() ? .orderedAscending : .orderedDescending

        case .size:
            if a.size == b.size { return .orderedSame }
            /// Sizes are sorted descending by default (largest first), conforming to standard POSIX behavior.
            return a.size > b.size ? .orderedAscending : .orderedDescending

        case .mtime:
            return compareTimes(a.modificationTime, b.modificationTime)

        case .atime:
            return compareTimes(a.accessTime, b.accessTime)

        case .ctime:
            return compareTimes(a.changeTime, b.changeTime)

        case .extension:
            let aExt = aName.split(separator: ".").last.map(String.init) ?? ""
            let bExt = bName.split(separator: ".").last.map(String.init) ?? ""
            if aExt == bExt { return .orderedSame }
            return aExt < bExt ? .orderedAscending : .orderedDescending
            
        case .version:
            /// Performs natural version sorting via localized standard comparison.
            if aName == bName { return .orderedSame }
            return aName.localizedStandardCompare(bName)
            
        case .none:
            return .orderedSame
        }
    }

    private func compareTimes(_ aTime: timespec, _ bTime: timespec) -> ComparisonResult {
        /// Timestamps are sorted descending by default (newest first).
        if aTime.tv_sec != bTime.tv_sec {
            return aTime.tv_sec > bTime.tv_sec ? .orderedAscending : .orderedDescending
        }
        if aTime.tv_nsec != bTime.tv_nsec {
            return aTime.tv_nsec > bTime.tv_nsec ? .orderedAscending : .orderedDescending
        }
        return .orderedSame
    }
}
