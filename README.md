# libark

`libark` is a modern, secure, Swift-native foundational layer over Linux POSIX primitives. 

While originally developed as the core runtime layer for **ArkOS**, `libark` is completely decoupled and designed to be used on **any Linux distribution**. It provides highly secure, object-oriented abstractions over low-level system calls, memory management, and file system interactions, without the burden of manual C interoperability.

## Features

- **Object-Oriented POSIX**: Wraps file descriptors, paths, and directory operations in safe, RAII-compliant Swift types.
- **Secure Syscall Boundary**: Routes kernel interactions through strict, audited `Syscall` primitives.
- **Terminal Capabilities**: Built-in abstractions for TTY detection and window sizing.
- **Advanced Formatting**: Standardized formatters for human-readable byte sizes (SI and IEC), ISO 8601 timestamps, permissions, and classifications.
- **Declarative Sorting**: Powerful generic `SortEngine` for metadata sorting across multiple criteria.

## Getting Started

To use `libark` in your Swift project on any Linux distribution, add it as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ARK-OS-Swift-and-Linux/libark.git", from: "1.0.0")
]
```

## Usage Examples

Here is a quick example of how you can use `libark` to read directory contents, extract metadata, and format the output:

```swift
import libark

do {
    // Safely open and read a directory using RAII
    let dir = try Directory(path: Path("/var/log"))
    var files: [FileMetadata] = []
    
    for entry in dir {
        guard let metadata = try? FileMetadata.lstat(path: Path("/var/log").join(entry.name)) else { continue }
        files.append(metadata)
    }

    // Declaratively sort by Size (descending), then Name
    let engine = SortEngine(criteria: [.size, .name])
    let sortedFiles = engine.sort(files)

    // Format and print
    for file in sortedFiles {
        let sizeString = ByteSize(file.size).humanReadable(format: .iec) // e.g., "1.4 MiB"
        let timeString = Timestamp(file.modificationTime).humanReadable(format: .iso)
        let permissions = PermissionFormatter.format(metadata: file) // e.g., "-rw-r--r--"
        
        print("\(permissions) \(sizeString)\t\(timeString)\t\(file.path.filename ?? "")")
    }
} catch {
    print("Error: \(error)")
}
```

## Documentation

Comprehensive documentation is available in the `docs/` directory:
- [Architecture](docs/Architecture.md): Overview of the system boundaries and design philosophy.
- [Filesystem](docs/Filesystem.md): Working with Paths, Directories, and File Descriptors.
- [Formatting](docs/Formatting.md): Presentation and utility formatters.

## License

`libark` is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
