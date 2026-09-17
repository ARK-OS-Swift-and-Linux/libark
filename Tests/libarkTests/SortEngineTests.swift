import XCTest
@testable import libark

final class SortEngineTests: XCTestCase {
    
    private func createMetadata(name: String, size: Int = 0, mtimeSec: Int = 0) -> FileMetadata {
        var st = stat()
        st.st_size = size
        st.st_mtim = timespec(tv_sec: mtimeSec, tv_nsec: 0)
        return FileMetadata(stat: st, path: Path(name))
    }
    
    func testSortByName() {
        let files = [
            createMetadata(name: "zebra.txt"),
            createMetadata(name: "Apple.txt"),
            createMetadata(name: "banana.txt")
        ]
        
        let engine = SortEngine(criteria: [.name])
        let sorted = engine.sort(files)
        
        XCTAssertEqual(sorted.map { $0.path.string }, ["Apple.txt", "banana.txt", "zebra.txt"])
    }
    
    func testSortBySize() {
        let files = [
            createMetadata(name: "small.txt", size: 10),
            createMetadata(name: "large.txt", size: 1000),
            createMetadata(name: "medium.txt", size: 100)
        ]
        
        let engine = SortEngine(criteria: [.size])
        let sorted = engine.sort(files)
        
        XCTAssertEqual(sorted.map { $0.path.string }, ["large.txt", "medium.txt", "small.txt"]) // Size descending
    }
    
    func testSortByMtime() {
        let files = [
            createMetadata(name: "old.txt", mtimeSec: 1000),
            createMetadata(name: "new.txt", mtimeSec: 3000),
            createMetadata(name: "medium.txt", mtimeSec: 2000)
        ]
        
        let engine = SortEngine(criteria: [.mtime])
        let sorted = engine.sort(files)
        
        XCTAssertEqual(sorted.map { $0.path.string }, ["new.txt", "medium.txt", "old.txt"]) // Time descending
    }
    
    func testSortByExtension() {
        let files = [
            createMetadata(name: "file.zip"),
            createMetadata(name: "file.txt"),
            createMetadata(name: "file.app")
        ]
        
        let engine = SortEngine(criteria: [.extension])
        let sorted = engine.sort(files)
        
        XCTAssertEqual(sorted.map { $0.path.string }, ["file.app", "file.txt", "file.zip"])
    }
    
    func testSortReverse() {
        let files = [
            createMetadata(name: "a.txt"),
            createMetadata(name: "b.txt"),
            createMetadata(name: "c.txt")
        ]
        
        let engine = SortEngine(criteria: [.name], reverse: true)
        let sorted = engine.sort(files)
        
        XCTAssertEqual(sorted.map { $0.path.string }, ["c.txt", "b.txt", "a.txt"])
    }
    
    func testSortMultipleCriteria() {
        let files = [
            createMetadata(name: "z.txt", size: 100), // Same size, different names
            createMetadata(name: "a.txt", size: 100),
            createMetadata(name: "b.txt", size: 500)
        ]
        
        let engine = SortEngine(criteria: [.size, .name])
        let sorted = engine.sort(files)
        
        // 500 comes first (size desc). Then 100 and 100 tie on size, sorted by name asc.
        XCTAssertEqual(sorted.map { $0.path.string }, ["b.txt", "a.txt", "z.txt"])
    }
}
