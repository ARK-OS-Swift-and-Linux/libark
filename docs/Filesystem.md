# Filesystem Subsystem

The Filesystem subsystem is the largest component of `libark`. It replaces manual string manipulation and direct libc calls with object-oriented Swift types.

## `Path`
A robust abstraction for canonicalizing, joining, and parsing filesystem paths. It handles relative resolution, trailing slashes, and extraction of extensions and filenames.

## `FileDescriptor`
A reference-counted wrapper around a raw UNIX file descriptor (integer). 
When a `FileDescriptor` falls out of scope, its internal `close()` is automatically invoked if it hasn't been closed already, preventing resource leaks.

## `Directory` and `DirectoryWalker`
Provides safe, iterative extraction of directory contents. 
`DirectoryWalker` extends this by offering recursive traversal, lazily fetching metadata and managing directory depths to prevent memory explosion on massive file trees.

## `FileMetadata`
Encapsulates `struct stat` from the kernel. Exposes heavily used properties (size, permissions, types, ownership, and precision timestamps) as strongly typed Swift primitives.

## `SortEngine`
A declarative metadata sorting system. Instead of writing custom comparators, consumers construct a `SortEngine` with a prioritized list of `SortCriteria` (e.g., `[.size, .name]`). The engine handles stable sorting across heterogeneous metadata.
