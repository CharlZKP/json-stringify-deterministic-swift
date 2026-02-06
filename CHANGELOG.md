# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-06

### Added
- Initial Swift port of json-stringify-deterministic (matched with v1.0.12)
- Deterministic JSON serialization with alphabetically sorted object keys
- Support for custom replacer functions
- Support for custom key comparison functions
- Optional pretty printing with configurable spacing
- Optional circular reference handling with `[Circular]` placeholder
- Command line tool for easy testing
- Full test suite with 30 tests covering all features
- Cross-platform support (Linux via Docker)

### Differences from JavaScript version
- No `toJSON()` support (use Swift's `Codable` instead)
- Swift dictionaries are value types (affects circular reference behavior)
- Type-safe implementation with compile-time checks
