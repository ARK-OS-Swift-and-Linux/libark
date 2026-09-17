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
