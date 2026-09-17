# Formatting Subsystem

The Formatting subsystem ensures that all tools utilizing `libark` output information in a consistent, standardized, and culturally aware manner. 

## `ByteSize`
Converts raw bytes into human-readable strings. It strictly delineates between base-10 SI (1000 bytes = 1 KB) and base-2 IEC (1024 bytes = 1 KiB) formats to prevent unit confusion.

## `TimeFormat`
A `Timestamp` wrapper around UNIX `timespec` that securely leverages `strftime`. It provides declarative presentation styles via the `TimeStyle` enum, supporting ISO 8601 variants, localized outputs, and nanosecond precision.

## Presentation Formatters
Found in `Formatters.swift`, these stateless structs convert low-level filesystem states into recognizable UNIX presentation formats:
- **`PermissionFormatter`**: Converts `FileType` and `Permissions` into the standard 10-character string (e.g., `drwxr-xr-x`).
- **`FileTypeFormatter`**: Extracts the single character classification (`d`, `l`, `-`).
- **`OwnerFormatter`**: Handles formatting User and Group IDs.
- **`NameFormatter`**: Decorates file names with suffixes indicating their type (e.g., `/` for directories, `*` for executables).
