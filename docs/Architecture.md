# Architecture

`libark` is built on the philosophy that systems programming should be memory-safe, expressive, and strictly bounded. It acts as an isolation layer between generic Swift applications and the raw C APIs of Linux (glibc).

## Core Principles

1. **Safe Boundaries**: Never expose raw pointers or naked file descriptors to the consumer. Resources should be managed via RAII (Resource Acquisition Is Initialization).
2. **Strict Syscall Routing**: Kernel interactions must pass through designated, audited bottlenecks (e.g., `Syscall._execute_secure`) to allow for tracing, seccomp integration, and security audits.
3. **Strong Typing**: Errors, file types, and permissions are represented as strictly typed enums and structs, eliminating the ambiguity of raw integers and bitmasks.

## Subsystems

### System Calls
The lowest level of `libark`. It abstracts raw CPU registers and standard `syscall()` invocations into Swift interfaces.

### Filesystem
Handles all interactions with disk. This includes directory traversal, file metadata extraction, symlink resolution, and descriptor-based I/O. 

### Terminal
Provides insights into the TTY environment, handling `ioctl` operations to determine window sizes, capabilities, and stream redirection.

### Formatting
A pure, logic-driven subsystem that converts internal structures (timestamps, bytes, permissions) into human-readable strings according to standardized specifications.
