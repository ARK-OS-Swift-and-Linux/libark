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
import Glibc
@testable import libark

final class ErrnoTests: XCTestCase {
    func testSystemErrorMapping() {
        XCTAssertEqual(SystemError(errNo: ENOENT), .noSuchFile)
        XCTAssertEqual(SystemError(errNo: ENOENT).errNo, ENOENT)
        
        XCTAssertEqual(SystemError(errNo: EACCES), .permissionDenied)
        XCTAssertEqual(SystemError(errNo: EPERM), .permissionDenied)
        XCTAssertEqual(SystemError(errNo: EACCES).errNo, EACCES) // EACCES is the default errNo for permissionDenied
        
        XCTAssertEqual(SystemError(errNo: ENOTDIR), .notDirectory)
        XCTAssertEqual(SystemError(errNo: EEXIST), .alreadyExists)
        XCTAssertEqual(SystemError(errNo: ENOTEMPTY), .notEmpty)
        XCTAssertEqual(SystemError(errNo: EINVAL), .invalidArgument)
        XCTAssertEqual(SystemError(errNo: EINTR), .interrupted)
        XCTAssertEqual(SystemError(errNo: EBUSY), .busy)
        
        let unknownErrNo: Int32 = 9999
        XCTAssertEqual(SystemError(errNo: unknownErrNo), .unknown(unknownErrNo))
        XCTAssertEqual(SystemError(errNo: unknownErrNo).errNo, unknownErrNo)
    }
    
    func testDescription() {
        let noSuchFileStr = String(cString: strerror(ENOENT))
        XCTAssertEqual(SystemError(errNo: ENOENT).description, noSuchFileStr)
    }
}
