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

final class PermissionsTests: XCTestCase {
    func testBasicPermissions() {
        // 0755 = rwxr-xr-x
        let p1 = Permissions(mode: 0o755)
        XCTAssertEqual(p1.stringRepresentation, "rwxr-xr-x")
        XCTAssertEqual(p1.octalValue, 0o755)
        
        // 0644 = rw-r--r--
        let p2 = Permissions(mode: 0o644)
        XCTAssertEqual(p2.stringRepresentation, "rw-r--r--")
        XCTAssertEqual(p2.octalValue, 0o644)
        
        // 0000 = ---------
        let p3 = Permissions(mode: 0o000)
        XCTAssertEqual(p3.stringRepresentation, "---------")
        XCTAssertEqual(p3.octalValue, 0o000)
        
        // 0777 = rwxrwxrwx
        let p4 = Permissions(mode: 0o777)
        XCTAssertEqual(p4.stringRepresentation, "rwxrwxrwx")
        XCTAssertEqual(p4.octalValue, 0o777)
    }
    
    func testSpecialBits() {
        // setuid, no execute (4644 = rwSr--r--)
        let p1 = Permissions(mode: 0o4644)
        XCTAssertEqual(p1.stringRepresentation, "rwSr--r--")
        XCTAssertEqual(p1.octalValue, 0o4644)
        
        // setuid, execute (4755 = rwsr-xr-x)
        let p2 = Permissions(mode: 0o4755)
        XCTAssertEqual(p2.stringRepresentation, "rwsr-xr-x")
        XCTAssertEqual(p2.octalValue, 0o4755)
        
        // setgid, no execute (2644 = rw-r-Sr--)
        let p3 = Permissions(mode: 0o2644)
        XCTAssertEqual(p3.stringRepresentation, "rw-r-Sr--")
        XCTAssertEqual(p3.octalValue, 0o2644)
        
        // setgid, execute (2775 = rwxrwsr-x)
        let p4 = Permissions(mode: 0o2775)
        XCTAssertEqual(p4.stringRepresentation, "rwxrwsr-x")
        XCTAssertEqual(p4.octalValue, 0o2775)
        
        // sticky, no execute (1644 = rw-r--r-T)
        let p5 = Permissions(mode: 0o1644)
        XCTAssertEqual(p5.stringRepresentation, "rw-r--r-T")
        XCTAssertEqual(p5.octalValue, 0o1644)
        
        // sticky, execute (1777 = rwxrwxrwt)
        let p6 = Permissions(mode: 0o1777)
        XCTAssertEqual(p6.stringRepresentation, "rwxrwxrwt")
        XCTAssertEqual(p6.octalValue, 0o1777)
        
        // all special bits and execute (7777 = rwsrwsrwt)
        let p7 = Permissions(mode: 0o7777)
        XCTAssertEqual(p7.stringRepresentation, "rwsrwsrwt")
        XCTAssertEqual(p7.octalValue, 0o7777)
    }
}
