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
import Glibc

public enum TimeStyle {
    case locale
    case iso
    case longIso
    case fullIso
    case custom(String)
}

public struct Timestamp: Equatable {
    public let sec: Int
    public let nsec: Int
    
    public init(sec: Int, nsec: Int) {
        self.sec = sec
        self.nsec = nsec
    }
    
    public init(_ ts: timespec) {
        self.sec = Int(ts.tv_sec)
        self.nsec = Int(ts.tv_nsec)
    }
    
    public func humanReadable(format: TimeStyle) -> String {
        var t = time_t(self.sec)
        var tm = Glibc.tm()
        localtime_r(&t, &tm)
        
        let formatStr: String
        switch format {
        case .locale:
            /// POSIX locale representation. Drops the year in favor of the time for timestamps within 6 months.
            let now = time(nil)
            if abs(now - t) > (6 * 30 * 24 * 3600) {
                formatStr = "%b %e  %Y"
            } else {
                formatStr = "%b %e %H:%M"
            }
        case .iso:
            formatStr = "%Y-%m-%d %H:%M:%S"
        case .longIso:
            formatStr = "%Y-%m-%d %H:%M"
        case .fullIso:
            /// Escapes the nanosecond token (`%N`) for manual replacement since standard `strftime` lacks native `%N` support.
            formatStr = "%Y-%m-%d %H:%M:%S.%%N %z"
        case .custom(let customStr):
            formatStr = customStr
        }
        
        var buffer = [CChar](repeating: 0, count: 256)
        strftime(&buffer, buffer.count, formatStr, &tm)
        
        /// Determine string length dynamically to avoid trailing null terminators in the output.
        let len = buffer.firstIndex(of: 0) ?? buffer.count
        var result = String(validating: buffer[..<len], as: UTF8.self) ?? ""
        
        /// Process manual `%N` expansion for nanoseconds if present.
        if result.contains("%N") {
            let nsecStr = String(format: "%09d", self.nsec)
            result = result.replacingOccurrences(of: "%N", with: nsecStr)
        }
        
        return result
    }
}
