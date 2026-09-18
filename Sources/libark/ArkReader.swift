import Foundation

/// A utility to read and parse .ark script files.
public struct ArkReader {
    public let filePath: String
    
    public init(filePath: String) {
        self.filePath = filePath
    }
    
    /// Reads the .ark file and returns a list of executable lines
    /// Empty lines and comments (starting with #) are ignored.
    public func readLines() throws -> [String] {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        return content.split(separator: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                return nil
            }
            return trimmed
        }
    }
}
