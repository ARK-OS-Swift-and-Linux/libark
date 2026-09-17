import Foundation

public enum ByteFormat {
    /// International System of Units (Base-10): KB, MB, GB
    case si
    /// International Electrotechnical Commission (Base-2): KiB, MiB, GiB
    case iec
}

public struct ByteSize: Equatable, Comparable {
    public let bytes: UInt64
    
    public init(_ bytes: UInt64) {
        self.bytes = bytes
    }
    
    public init(_ bytes: Int) {
        // Technically we can't represent negative byte sizes safely in this struct,
        // but for formatting it's fine. We clamp to 0 if negative.
        self.bytes = UInt64(max(0, bytes))
    }
    
    public static func < (lhs: ByteSize, rhs: ByteSize) -> Bool {
        return lhs.bytes < rhs.bytes
    }
    
    /// Formats the byte size according to the requested format.
    /// Example: 1024 bytes -> "1.0 KiB" (iec) or "1.0 KB" (si)
    public func humanReadable(format: ByteFormat) -> String {
        let base: Double
        let suffixes: [String]
        
        switch format {
        case .si:
            base = 1000.0
            suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB"]
        case .iec:
            base = 1024.0
            suffixes = ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB"]
        }
        
        if bytes < UInt64(base) {
            return "\(bytes) \(suffixes[0])"
        }
        
        let val = Double(bytes)
        let exp = Int(log(val) / log(base))
        
        // Cap the exponent to our available suffixes
        let maxExp = suffixes.count - 1
        let finalExp = min(exp, maxExp)
        
        let size = val / pow(base, Double(finalExp))
        
        // Determine precision.
        // If it's a clean integer or close to it, maybe no decimal?
        // standard is usually 1 decimal place (e.g. "1.2 MB").
        // We can format it nicely.
        
        let sizeString = String(format: "%.1f", size)
        
        // Remove trailing ".0" if present? The user requested "1.0K", so we'll keep the .0
        
        return "\(sizeString) \(suffixes[finalExp])"
    }
    
    /// Short format, exactly as requested: "1.0K", "1.0M", "1.0G".
    /// This generally implies Base-10 or Base-2 but omits the 'B' or 'iB'.
    /// Usually `ls -h` uses Base-2 with short suffixes.
    public func humanReadableShort(format: ByteFormat = .iec) -> String {
        let base: Double
        let suffixes: [String]
        
        switch format {
        case .si:
            base = 1000.0
            suffixes = ["", "K", "M", "G", "T", "P", "E"]
        case .iec:
            base = 1024.0
            suffixes = ["", "K", "M", "G", "T", "P", "E"]
        }
        
        if bytes < UInt64(base) {
            return "\(bytes)"
        }
        
        let val = Double(bytes)
        let exp = Int(log(val) / log(base))
        
        let maxExp = suffixes.count - 1
        let finalExp = min(exp, maxExp)
        
        let size = val / pow(base, Double(finalExp))
        
        let sizeString = String(format: "%.1f", size)
        return "\(sizeString)\(suffixes[finalExp])"
    }
}

// Extensions for convenience
extension UInt64 {
    public var bytes: ByteSize { ByteSize(self) }
}

extension Int {
    public var bytes: ByteSize { ByteSize(self) }
}
