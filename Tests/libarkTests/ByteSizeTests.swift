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

import XCTest
@testable import libark

final class ByteSizeTests: XCTestCase {
    
    func testSIFormatting() throws {
        XCTAssertEqual(1000.bytes.humanReadable(format: .si), "1.0 KB")
        XCTAssertEqual(1024.bytes.humanReadable(format: .si), "1.0 KB")
        XCTAssertEqual(1500.bytes.humanReadable(format: .si), "1.5 KB")
        XCTAssertEqual(1_000_000.bytes.humanReadable(format: .si), "1.0 MB")
        XCTAssertEqual(1_500_000.bytes.humanReadable(format: .si), "1.5 MB")
        XCTAssertEqual(1_000_000_000.bytes.humanReadable(format: .si), "1.0 GB")
    }
    
    func testIECFormatting() throws {
        XCTAssertEqual(1000.bytes.humanReadable(format: .iec), "1000 B")
        XCTAssertEqual(1024.bytes.humanReadable(format: .iec), "1.0 KiB")
        XCTAssertEqual(1536.bytes.humanReadable(format: .iec), "1.5 KiB")
        XCTAssertEqual(1_048_576.bytes.humanReadable(format: .iec), "1.0 MiB")
        XCTAssertEqual(1_073_741_824.bytes.humanReadable(format: .iec), "1.0 GiB")
    }
    
    func testShortFormatting() throws {
        // As requested by user: 1024 -> 1.0K, 1048576 -> 1.0M, 1073741824 -> 1.0G
        XCTAssertEqual(1024.bytes.humanReadableShort(format: .iec), "1.0K")
        XCTAssertEqual(1_048_576.bytes.humanReadableShort(format: .iec), "1.0M")
        XCTAssertEqual(1_073_741_824.bytes.humanReadableShort(format: .iec), "1.0G")
    }
}
