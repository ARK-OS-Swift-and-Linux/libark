# Contributing to libark

We welcome contributions from the community! Whether you're fixing a bug, improving documentation, or proposing a new feature, your help is appreciated. 

Because `libark` acts as a foundational system layer across all Linux distributions, we maintain strict standards for code quality and security.

## How to Contribute

1. **Open an Issue**: Before submitting a major Pull Request, please open an issue to discuss your proposed changes.
2. **Fork the Repository**: Create a fork and branch for your feature or bugfix.
3. **Write Tests**: `libark` strives for high test coverage. Any new abstraction or utility must include corresponding XCTest cases.
4. **Follow Swift Guidelines**: Ensure your code is clean, idiomatic Swift. Use proper documentation blocks (`///`) for all public APIs.
5. **Submit a Pull Request**: Provide a clear, detailed description of your changes, the rationale behind them, and any related issue numbers.

## Development Setup

```bash
git clone https://github.com/ARK-OS-Swift-and-Linux/libark.git
cd libark
swift test
```

Please ensure `swift test` passes locally on a standard Linux environment before submitting your PR.
