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

final class PathTests: XCTestCase {
    
    func testParsingAndString() {
        let p1 = Path("/a/b/c")
        XCTAssertEqual(p1.components, [.root, .name("a"), .name("b"), .name("c")])
        XCTAssertEqual(p1.string, "/a/b/c")
        XCTAssertTrue(p1.isAbsolute)
        
        let p2 = Path("a/b/../c/.")
        XCTAssertEqual(p2.components, [.name("a"), .name("b"), .parent, .name("c"), .current])
        XCTAssertEqual(p2.string, "a/b/../c/.")
        XCTAssertFalse(p2.isAbsolute)
        
        let p3 = Path("/")
        XCTAssertEqual(p3.components, [.root])
        XCTAssertEqual(p3.string, "/")
        
        let p4 = Path("")
        XCTAssertEqual(p4.components, [.current])
        XCTAssertEqual(p4.string, ".")
    }
    
    func testNormalization() {
        let p1 = Path("/a/b/../c").normalize()
        XCTAssertEqual(p1.string, "/a/c")
        
        let p2 = Path("a/./b/./c").normalize()
        XCTAssertEqual(p2.string, "a/b/c")
        
        let p3 = Path("/../..").normalize()
        XCTAssertEqual(p3.string, "/")
        
        let p4 = Path("a/b/../../..").normalize()
        XCTAssertEqual(p4.string, "..")
        
        let p5 = Path("./a").normalize()
        XCTAssertEqual(p5.string, "a")
    }
    
    func testProperties() {
        let p = Path("/var/log/syslog.1.gz")
        XCTAssertEqual(p.parent?.string, "/var/log")
        XCTAssertEqual(p.filename, "syslog.1.gz")
        XCTAssertEqual(p.extension, "gz")
        XCTAssertEqual(p.stem, "syslog.1")
        
        let hidden = Path("/home/user/.bashrc")
        XCTAssertEqual(hidden.filename, ".bashrc")
        XCTAssertNil(hidden.extension)
        XCTAssertEqual(hidden.stem, ".bashrc")
    }
    
    func testJoin() {
        let p1 = Path("/var")
        let p2 = p1.join("log/syslog")
        XCTAssertEqual(p2.string, "/var/log/syslog")
        
        let p3 = p1.join("/etc/passwd")
        XCTAssertEqual(p3.string, "/etc/passwd")
    }
    
    func testRelative() {
        let p1 = Path("/home/user/src/arkrt")
        let base = Path("/home/user")
        XCTAssertEqual(p1.relative(to: base).string, "src/arkrt")
        
        let p2 = Path("/etc/passwd")
        XCTAssertEqual(p2.relative(to: base).string, "../../etc/passwd")
    }
    
    func testResolve() {
        let p = Path("src/../log")
        let absolute = p.resolve(cwd: Path("/home/user"))
        XCTAssertEqual(absolute.string, "/home/user/log")
    }
    
    func testCanonicalize() throws {
        // Create a temporary structure
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        let target = tempDir.appendingPathComponent("target.txt")
        try "hello".write(to: target, atomically: true, encoding: .utf8)
        
        let symlink = tempDir.appendingPathComponent("link.txt")
        try FileManager.default.createSymbolicLink(atPath: symlink.path, withDestinationPath: target.path)
        
        let path = Path(symlink.path)
        let canonical = try path.canonicalize()
        XCTAssertEqual(canonical.string, target.path)
    }
    
    func testRepeatedSlashes() {
        let p1 = Path("/a///b////c")
        XCTAssertEqual(p1.string, "/a/b/c")
        XCTAssertEqual(p1.components, [.root, .name("a"), .name("b"), .name("c")])
        
        let p2 = Path("///")
        XCTAssertEqual(p2.string, "/")
        XCTAssertEqual(p2.components, [.root])
        
        let p3 = Path("a///b")
        XCTAssertEqual(p3.string, "a/b")
        XCTAssertEqual(p3.components, [.name("a"), .name("b")])
        
        let p4 = Path("/a//b//")
        XCTAssertEqual(p4.string, "/a/b/")
        XCTAssertTrue(p4.hasTrailingSlash)
    }
    
    func testRelativeParentTraversal() {
        // Leading uncancelled '..' preserved
        let p1 = Path("a/../../b").normalize()
        XCTAssertEqual(p1.string, "../b")
        
        let p2 = Path("../../..").normalize()
        XCTAssertEqual(p2.string, "../../..")
        
        let p3 = Path("../../a/..").normalize()
        XCTAssertEqual(p3.string, "../..")
        
        let p4 = Path("../a/../b").normalize()
        XCTAssertEqual(p4.string, "../b")
        
        let p5 = Path("./..").normalize()
        XCTAssertEqual(p5.string, "..")
    }
    
    func testAbsoluteRootEscaping() {
        // '..' cannot escape root on absolute paths
        let p1 = Path("/..").normalize()
        XCTAssertEqual(p1.string, "/")
        
        let p2 = Path("/../../..").normalize()
        XCTAssertEqual(p2.string, "/")
        
        let p3 = Path("/a/../../b").normalize()
        XCTAssertEqual(p3.string, "/b")
        
        let p4 = Path("/../../a").normalize()
        XCTAssertEqual(p4.string, "/a")
    }
    
    func testEmptyAndCurrentDirectoryNormalization() {
        let p1 = Path("").normalize()
        XCTAssertEqual(p1.string, ".")
        
        let p2 = Path(".").normalize()
        XCTAssertEqual(p2.string, ".")
        
        let p3 = Path("./.").normalize()
        XCTAssertEqual(p3.string, ".")
        
        let p4 = Path("a/..").normalize()
        XCTAssertEqual(p4.string, ".")
        
        let p5 = Path("./a").normalize()
        XCTAssertEqual(p5.string, "a")
    }
    
    func testTrailingSlashes() {
        let p1 = Path("/var/log/")
        XCTAssertTrue(p1.hasTrailingSlash)
        XCTAssertEqual(p1.string, "/var/log/")
        XCTAssertEqual(p1.filename, "log")
        
        let norm1 = p1.normalize()
        XCTAssertFalse(norm1.hasTrailingSlash)
        XCTAssertEqual(norm1.string, "/var/log")
        
        let normPreserved = p1.normalize(preserveTrailingSlash: true)
        XCTAssertTrue(normPreserved.hasTrailingSlash)
        XCTAssertEqual(normPreserved.string, "/var/log/")
        
        let p2 = Path("a/b/")
        XCTAssertTrue(p2.hasTrailingSlash)
        XCTAssertEqual(p2.string, "a/b/")
        XCTAssertEqual(p2.normalize().string, "a/b")
        
        let pRoot = Path("/")
        XCTAssertFalse(pRoot.hasTrailingSlash)
        XCTAssertEqual(pRoot.string, "/")
        
        let pEmpty = Path("")
        XCTAssertFalse(pEmpty.hasTrailingSlash)
        XCTAssertEqual(pEmpty.string, ".")
    }
    
    func testFilenameStemAndExtension() {
        // Dotfile without secondary extension
        let bashrc = Path("/home/user/.bashrc")
        XCTAssertEqual(bashrc.filename, ".bashrc")
        XCTAssertNil(bashrc.extension)
        XCTAssertEqual(bashrc.stem, ".bashrc")
        
        // Dotfile starting with multiple dots and no secondary extension
        let doubleDot = Path("/home/user/..bashrc")
        XCTAssertEqual(doubleDot.filename, "..bashrc")
        XCTAssertNil(doubleDot.extension)
        XCTAssertEqual(doubleDot.stem, "..bashrc")
        
        // Dotfile with secondary extension
        let tarGzHidden = Path("/tmp/.tar.gz")
        XCTAssertEqual(tarGzHidden.filename, ".tar.gz")
        XCTAssertEqual(tarGzHidden.extension, "gz")
        XCTAssertEqual(tarGzHidden.stem, ".tar")
        
        // Multi-dot regular file
        let archive = Path("/downloads/archive.tar.gz")
        XCTAssertEqual(archive.filename, "archive.tar.gz")
        XCTAssertEqual(archive.extension, "gz")
        XCTAssertEqual(archive.stem, "archive.tar")
        
        // Extensionless file
        let makefile = Path("/src/Makefile")
        XCTAssertEqual(makefile.filename, "Makefile")
        XCTAssertNil(makefile.extension)
        XCTAssertEqual(makefile.stem, "Makefile")
        
        // Trailing dot
        let trailingDot = Path("/src/file.")
        XCTAssertEqual(trailingDot.filename, "file.")
        XCTAssertNil(trailingDot.extension)
        XCTAssertEqual(trailingDot.stem, "file.")
        
        // Special root/empty/dot paths
        XCTAssertNil(Path("/").filename)
        XCTAssertNil(Path("/").extension)
        XCTAssertNil(Path("/").stem)
        
        XCTAssertNil(Path(".").filename)
        XCTAssertNil(Path(".").extension)
        XCTAssertNil(Path(".").stem)
        
        XCTAssertNil(Path("..").filename)
        XCTAssertNil(Path("..").extension)
        XCTAssertNil(Path("..").stem)
        
        // Path with trailing slash preserves filename
        let dirPath = Path("/var/log/")
        XCTAssertEqual(dirPath.filename, "log")
        XCTAssertEqual(dirPath.stem, "log")
        XCTAssertNil(dirPath.extension)
    }
    
    func testParentNavigation() {
        XCTAssertEqual(Path("/var/log/syslog.1.gz").parent?.string, "/var/log")
        XCTAssertEqual(Path("/var").parent?.string, "/")
        XCTAssertNil(Path("/").parent)
        XCTAssertEqual(Path("a/b").parent?.string, "a")
        XCTAssertEqual(Path("a").parent?.string, ".")
        XCTAssertEqual(Path(".").parent?.string, ".")
        XCTAssertEqual(Path("..").parent?.string, ".")
        XCTAssertEqual(Path("../..").parent?.string, "..")
        XCTAssertEqual(Path("../../..").parent?.string, "../..")
    }
    
    func testEqualityAndHashingWithTrailingSlashes() {
        let pWithSlash = Path("/var/log/")
        let pWithoutSlash = Path("/var/log")
        
        // Paths differing only by trailing slash compare equal
        XCTAssertEqual(pWithSlash, pWithoutSlash)
        
        // Equal values have equal hashes
        XCTAssertEqual(pWithSlash.hashValue, pWithoutSlash.hashValue)
        
        // Set deduplicates paths differing only by trailing slash
        let set: Set<Path> = [pWithSlash, pWithoutSlash]
        XCTAssertEqual(set.count, 1)
        
        // hasTrailingSlash metadata is independently preserved and inspectable
        XCTAssertTrue(pWithSlash.hasTrailingSlash)
        XCTAssertFalse(pWithoutSlash.hasTrailingSlash)
        XCTAssertNotEqual(pWithSlash.hasTrailingSlash, pWithoutSlash.hasTrailingSlash)
        
        // Relative paths with and without trailing slash
        let relWithSlash = Path("a/b/")
        let relWithoutSlash = Path("a/b")
        XCTAssertEqual(relWithSlash, relWithoutSlash)
        XCTAssertEqual(relWithSlash.hashValue, relWithoutSlash.hashValue)
        XCTAssertTrue(relWithSlash.hasTrailingSlash)
        XCTAssertFalse(relWithoutSlash.hasTrailingSlash)
        
        // Comparable consistency: equal paths cannot be less than each other
        XCTAssertFalse(pWithSlash < pWithoutSlash)
        XCTAssertFalse(pWithoutSlash < pWithSlash)
        XCTAssertFalse(relWithSlash < relWithoutSlash)
        XCTAssertFalse(relWithoutSlash < relWithSlash)
    }
    
    func testNormalizationIdempotence() {
        let cases = [
            "/a/b/../c",
            "/var/log/",
            "///",
            "/..",
            "/a/../../b",
            "a/../../b",
            "a/b/",
            "a/./b/./c",
            "",
            ".",
            "..",
            "../..",
            "../../.."
        ]
        
        for input in cases {
            let p = Path(input)
            let norm1 = p.normalize()
            let norm2 = norm1.normalize()
            XCTAssertEqual(norm1, norm2, "Normalization must be idempotent for '\(input)'")
            XCTAssertEqual(norm1.string, norm2.string, "Normalized string must be identical for '\(input)'")
            XCTAssertEqual(norm1.hasTrailingSlash, norm2.hasTrailingSlash, "Trailing slash metadata must be identical after repeated normalization for '\(input)'")
        }
    }
    
    func testJoinAndOperators() {
        let p1 = Path("/var")
        let p2 = p1 / "log"
        XCTAssertEqual(p2.string, "/var/log")
        
        let p3 = p1 / Path("log")
        XCTAssertEqual(p3.string, "/var/log")
        
        let p4 = p1 / "/etc/passwd"
        XCTAssertEqual(p4.string, "/etc/passwd")
        
        let p5 = Path("a") / ""
        XCTAssertEqual(p5.string, "a")
        
        let p6 = Path("") / "b"
        XCTAssertEqual(p6.string, "b")
        
        let p7 = Path("a") / "b/"
        XCTAssertTrue(p7.hasTrailingSlash)
        XCTAssertEqual(p7.string, "a/b/")
    }
    
    func testConformances() {
        // ExpressibleByStringLiteral
        let literalPath: Path = "/etc/hosts"
        XCTAssertEqual(literalPath.string, "/etc/hosts")
        XCTAssertTrue(literalPath.isAbsolute)
        XCTAssertFalse(literalPath.isRelative)
        
        // Hashable in Set
        let set: Set<Path> = [Path("/a"), Path("/b"), Path("/a")]
        XCTAssertEqual(set.count, 2)
        
        // Comparable
        let unsorted: [Path] = [Path("/c"), Path("/a"), Path("/b")]
        let sorted = unsorted.sorted()
        XCTAssertEqual(sorted.map(\.string), ["/a", "/b", "/c"])
        
        // Relative property
        XCTAssertTrue(Path("src/libark").isRelative)
        XCTAssertFalse(Path("/src/libark").isRelative)
    }
    
    func testStrictWeakOrderingAndComponentIdentity() {
        // Strict total ordering across component types:
        // .root < .current < .parent < .name(...)
        let pRoot = Path("/")
        let pCurrent = Path(".")
        let pParent = Path("..")
        let pAlpha = Path("a")
        let pBeta = Path("b")
        
        XCTAssertTrue(pRoot < pCurrent)
        XCTAssertTrue(pCurrent < pParent)
        XCTAssertTrue(pParent < pAlpha)
        XCTAssertTrue(pAlpha < pBeta)
        
        // Transitivity:
        XCTAssertTrue(pRoot < pParent)
        XCTAssertTrue(pRoot < pAlpha)
        XCTAssertTrue(pCurrent < pAlpha)
        
        // Irreflexivity:
        XCTAssertFalse(pRoot < pRoot)
        XCTAssertFalse(pCurrent < pCurrent)
        XCTAssertFalse(pParent < pParent)
        XCTAssertFalse(pAlpha < pAlpha)
        
        // Asymmetry:
        XCTAssertFalse(pCurrent < pRoot)
        XCTAssertFalse(pParent < pCurrent)
        XCTAssertFalse(pAlpha < pParent)
        XCTAssertFalse(pBeta < pAlpha)
        
        // Paths with '.' and '..'
        let pDotA = Path("./a")
        let pDotDotA = Path("../a")
        let pA = Path("a")
        let pAB = Path("a/b")
        let pB = Path("b")
        
        XCTAssertTrue(pDotA < pDotDotA)
        XCTAssertTrue(pDotDotA < pA)
        XCTAssertTrue(pA < pAB)
        XCTAssertTrue(pAB < pB)
        
        // Equal paths (including trailing slashes) must never be less than each other
        let pWithSlash = Path("/var/log/")
        let pWithoutSlash = Path("/var/log")
        XCTAssertEqual(pWithSlash, pWithoutSlash)
        XCTAssertFalse(pWithSlash < pWithoutSlash)
        XCTAssertFalse(pWithoutSlash < pWithSlash)
        
        // Component identity consistency:
        // Components sharing the same stringValue but having different enum identities
        // must be strictly ordered and not treated as equivalent in Comparable.
        let compCurrent = Path(components: [.current])
        let compNameDot = Path(components: [.name(".")])
        XCTAssertNotEqual(compCurrent, compNameDot)
        XCTAssertEqual(compCurrent.components[0].stringValue, compNameDot.components[0].stringValue)
        XCTAssertTrue(compCurrent < compNameDot)
        XCTAssertFalse(compNameDot < compCurrent)
        
        let compParent = Path(components: [.parent])
        let compNameDotDot = Path(components: [.name("..")])
        XCTAssertNotEqual(compParent, compNameDotDot)
        XCTAssertEqual(compParent.components[0].stringValue, compNameDotDot.components[0].stringValue)
        XCTAssertTrue(compParent < compNameDotDot)
        XCTAssertFalse(compNameDotDot < compParent)
        
        // Incomparability equivalence: !(a < b) && !(b < a) <=> a == b
        let samplePaths = [
            pRoot, pCurrent, pParent, pAlpha, pBeta,
            pDotA, pDotDotA, pA, pAB, pB,
            pWithSlash, pWithoutSlash,
            compCurrent, compNameDot, compParent, compNameDotDot
        ]
        
        for p1 in samplePaths {
            for p2 in samplePaths {
                let p1LessP2 = p1 < p2
                let p2LessP1 = p2 < p1
                let p1EqualP2 = p1 == p2
                
                if p1EqualP2 {
                    XCTAssertFalse(p1LessP2, "\(p1) and \(p2) compare equal but p1 < p2 is true")
                    XCTAssertFalse(p2LessP1, "\(p1) and \(p2) compare equal but p2 < p1 is true")
                } else {
                    XCTAssertTrue(p1LessP2 || p2LessP1, "\(p1) and \(p2) are not equal but neither is less than the other")
                    XCTAssertFalse(p1LessP2 && p2LessP1, "\(p1) and \(p2) cannot both be less than each other")
                }
            }
        }
    }
}
