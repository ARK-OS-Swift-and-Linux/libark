import XCTest
@testable import libark
import Glibc

final class DirectoryTests: XCTestCase {
    
    var testDir: String!
    var subDir: String!
    var file1: String!
    
    override func setUp() {
        super.setUp()
        testDir = "/tmp/libark_dir_tests_\(UUID().uuidString)"
        mkdir(testDir, 0o777)
        
        subDir = "\(testDir!)/subdir"
        mkdir(subDir, 0o777)
        
        file1 = "\(testDir!)/file1.txt"
        let fd = open(file1, O_CREAT | O_WRONLY, 0o644)
        if fd >= 0 {
            close(fd)
        }
    }
    
    override func tearDown() {
        unlink(file1)
        rmdir(subDir)
        rmdir(testDir)
        super.tearDown()
    }
    
    func testDirectoryRead() throws {
        let dir = try Directory.open(path: Path(testDir))
        let entries = Array(dir).map { $0.name }
        
        XCTAssertTrue(entries.contains("."))
        XCTAssertTrue(entries.contains(".."))
        XCTAssertTrue(entries.contains("subdir"))
        XCTAssertTrue(entries.contains("file1.txt"))
    }
    
    func testDirectoryEntryTypes() throws {
        let dir = try Directory.open(path: Path(testDir))
        for entry in dir {
            if entry.name == "subdir" {
                XCTAssertEqual(entry.type, .directory)
            } else if entry.name == "file1.txt" {
                XCTAssertEqual(entry.type, .regular)
            }
        }
    }
    
    func testDirectoryWalker() throws {
        let walker = DirectoryWalker(root: Path(testDir))
        let entries = Array(walker).map { $0.name }
        
        // Walker excludes . and ..
        XCTAssertFalse(entries.contains("."))
        XCTAssertFalse(entries.contains(".."))
        
        // Walker should find both top-level entries and recursive entries
        XCTAssertTrue(entries.contains("subdir"))
        XCTAssertTrue(entries.contains("file1.txt"))
    }
}
