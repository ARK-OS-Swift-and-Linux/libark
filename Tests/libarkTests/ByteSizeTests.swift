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
