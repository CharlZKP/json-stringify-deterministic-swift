# JSONStringifyDeterministic

Swift port of [json-stringify-deterministic](https://github.com/Kikobeats/json-stringify-deterministic) - deterministic JSON serialization for reproducible outputs.

Matched with original at version `1.0.12`.

## What It Does

Standard JSON serialization doesn't guarantee consistent output across different runs or environments. Object keys may be ordered differently, spacing may vary, and implementation details can cause subtle differences.

This library ensures **deterministic** JSON output by:

- Always sorting object keys alphabetically
- Applying consistent formatting rules
- Providing stable, reproducible serialization

This makes it ideal for:

- Generating stable content hashes for caching
- Creating reliable signatures for API responses
- Comparing JSON outputs in tests
- Ensuring consistent logging across distributed systems

## Features

- **Deterministic output**: Object keys always sorted alphabetically
- **Circular reference handling**: Optional support with `[Circular]` placeholder
- **Custom replacer functions**: Transform values during serialization
- **Custom key comparison**: Override default alphabetical sorting
- **Pretty printing**: Optional indentation with custom spacing

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/CharlZKP/json-stringify-deterministic-swift", from: "1.0.0")
]
```

## Usage

```swift
public func stringify(_ obj: Any, _ opts: Options? = nil) -> String
```

### Example

```swift
import JSONStringifyDeterministic

let obj: [String: Any] = ["c": 8, "b": [4, 5], "a": 3]
let result = stringify(obj)
// {"a":3,"b":[4,5],"c":8}
```

### Options

```swift
let result = stringify(obj, Options(
    space: "  ",        // Pretty print with 2 spaces
    cycles: true,        // Handle circular references
    replacer: { k, v in v },  // Transform values
    compare: { a, b in .orderedAscending }  // Custom key sort
))
```

```swift
public struct Options {
    public var space: String?
    public var cycles: Bool
    public var compare: ((KeyValue, KeyValue) -> ComparisonResult)?
    public var replacer: ((String, Any) -> Any?)?
}
```

## Testing

```bash
swift test
```

## Releasing

To create a release:

```bash
git tag 1.0.0
git push origin 1.0.0
```

Then create a GitHub Release (which automatically uses the tag).

## License

MIT - See [LICENSE](LICENSE) for details.

## Original

This is a Swift port of [json-stringify-deterministic](https://github.com/Kikobeats/json-stringify-deterministic) by [Kikobeats](https://github.com/Kikobeats).
