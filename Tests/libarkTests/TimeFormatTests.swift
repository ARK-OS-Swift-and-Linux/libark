import XCTest
@testable import libark
import Glibc

final class TimeFormatTests: XCTestCase {
    
    func testISOFormatting() throws {
        // Create a fixed time to test. 
        // 1672531200 is 2023-01-01 00:00:00 UTC
        // But since localtime_r is used in humanReadable, the output depends on the timezone.
        // We can test longIso which has no timezone output, but it still offsets by timezone.
        // Instead of testing exact string match which is timezone dependent, we test the pattern.
        
        let ts = Timestamp(sec: 1672531200, nsec: 123456789)
        
        let isoStr = ts.humanReadable(format: .iso)
        XCTAssertEqual(isoStr.count, 19, "ISO format should be 19 chars: YYYY-MM-DD HH:MM:SS")
        
        let longIsoStr = ts.humanReadable(format: .longIso)
        XCTAssertEqual(longIsoStr.count, 16, "Long ISO format should be 16 chars: YYYY-MM-DD HH:MM")
    }
    
    func testFullISOFormatting() throws {
        let ts = Timestamp(sec: 1672531200, nsec: 123456789)
        let fullIsoStr = ts.humanReadable(format: .fullIso)
        // Should contain nanoseconds
        XCTAssertTrue(fullIsoStr.contains("123456789"), "Full ISO should contain nanoseconds")
    }
    
    func testCustomFormatting() throws {
        let ts = Timestamp(sec: 1672531200, nsec: 123456789)
        let customStr = ts.humanReadable(format: .custom("%Y---%N"))
        XCTAssertTrue(customStr.hasSuffix("---123456789"), "Custom format should parse %N properly")
        XCTAssertTrue(customStr.hasPrefix("2022") || customStr.hasPrefix("2023"), "Should have correct year")
    }
}
