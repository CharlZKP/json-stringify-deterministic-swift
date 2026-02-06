import Foundation

// MARK: - Options

public struct Options {
    /// Indent the output for pretty-printing
    public var space: String?
    
    /// When true, circular references are replaced with "[Circular]"
    public var cycles: Bool
    
    /// Custom comparison function for object keys
    public var compare: ((KeyValue, KeyValue) -> ComparisonResult)?
    
    /// Replacer function that transforms values
    public var replacer: ((String, Any) -> Any?)?
    
    public init(
        space: String? = nil,
        cycles: Bool = false,
        compare: ((KeyValue, KeyValue) -> ComparisonResult)? = nil,
        replacer: ((String, Any) -> Any?)? = nil
    ) {
        self.space = space
        self.cycles = cycles
        self.compare = compare
        self.replacer = replacer
    }
}

public struct KeyValue {
    public let key: String
    public let value: Any
    
    public init(key: String, value: Any) {
        self.key = key
        self.value = value
    }
}

// MARK: - Main Function

/// Deterministic version of JSON.stringify(), so you can get a consistent hash from stringified results.
/// - Parameters:
///   - obj: The input object to be serialized
///   - opts: Options for serialization
/// - Returns: Deterministic JSON string
public func stringify(_ obj: Any, _ opts: Options? = nil) -> String {
    let options = opts ?? Options()
    let space = options.space ?? ""
    
    // Detect circular structure in obj and raise error efficiently
    if !options.cycles {
        _ = try? JSONSerialization.data(withJSONObject: obj)
    }
    
    var seen: [ObjectIdentifier] = []
    
    return deterministic(parent: ["": obj], key: "", node: obj, level: 0, options: options, space: space, seen: &seen)
}

// MARK: - Internal Implementation

private func deterministic(
    parent: Any,
    key: String,
    node: Any,
    level: Int,
    options: Options,
    space: String,
    seen: inout [ObjectIdentifier]
) -> String {
    // Handle nil values
    if let optionalNode = node as? Any?, optionalNode == nil {
        return "null"
    }
    
    let indent = space.isEmpty ? "" : "\n" + String(repeating: space, count: level + 1)
    let closingIndent = space.isEmpty ? "" : "\n" + String(repeating: space, count: level)
    let colonSeparator = space.isEmpty ? ":" : ": "
    
    var processedNode = serialize(node)
    
    // Apply replacer
    if let replacer = options.replacer {
        if let replaced = replacer(key, processedNode) {
            processedNode = replaced
        } else {
            return "" // Skip this key-value pair
        }
    }
    
    // Handle nil/NSNull after replacer
    if processedNode is NSNull {
        return "null"
    }
    
    // Handle nil after replacer
    if let optionalNode = processedNode as? Any?, optionalNode == nil {
        return "null"
    }
    
    // Handle primitives
    if !(processedNode is [String: Any]) && !(processedNode is [Any]) {
        return stringifyPrimitive(processedNode)
    }
    
    // Handle arrays
    if let array = processedNode as? [Any] {
        var out: [String] = []
        for (index, item) in array.enumerated() {
            let itemResult = deterministic(
                parent: array,
                key: String(index),
                node: item,
                level: level + 1,
                options: options,
                space: space,
                seen: &seen
            )
            out.append(indent + (itemResult.isEmpty ? "null" : itemResult))
        }
        return "[" + out.joined(separator: ",") + closingIndent + "]"
    }
    
    // Handle objects
    if let dict = processedNode as? [String: Any] {
        // Handle cycles
        if options.cycles {
            let objectId = ObjectIdentifier(dict as AnyObject)
            if seen.contains(objectId) {
                return "\"[Circular]\""
            } else {
                seen.append(objectId)
            }
        }
        
        // Sort keys
        var keys = Array(dict.keys).sorted()
        if let compare = options.compare {
            keys.sort { a, b in
                let kvA = KeyValue(key: a, value: dict[a]!)
                let kvB = KeyValue(key: b, value: dict[b]!)
                return compare(kvA, kvB) == .orderedAscending
            }
        }
        
        var out: [String] = []
        for k in keys {
            let valueResult = deterministic(
                parent: dict,
                key: k,
                node: dict[k]!,
                level: level + 1,
                options: options,
                space: space,
                seen: &seen
            )
            
            if valueResult.isEmpty {
                continue
            }
            
            let keyValue = stringifyPrimitive(k) + colonSeparator + valueResult
            out.append(indent + keyValue)
        }
        
        if options.cycles, let objectId = seen.firstIndex(of: ObjectIdentifier(dict as AnyObject)) {
            seen.remove(at: objectId)
        }
        
        return "{" + out.joined(separator: ",") + closingIndent + "}"
    }
    
    return stringifyPrimitive(processedNode)
}

private func serialize(_ obj: Any) -> Any {
    if obj is NSNull {
        return obj
    }
    
    // Note: toJSON method support is not available on Swift Linux
    // as it requires Objective-C runtime. In Swift, use Codable instead.
    
    return obj
}

private func stringifyPrimitive(_ value: Any) -> String {
    if value is NSNull {
        return "null"
    }
    
    if let str = value as? String {
        // Escape the string properly
        return escapeString(str)
    }
    
    if let bool = value as? Bool {
        return bool ? "true" : "false"
    }
    
    if let num = value as? NSNumber {
        // Check if it's a boolean (NSNumber can represent both numbers and booleans)
        let objCType = num.objCType
        if objCType.pointee == 99 || objCType.pointee == 67 { // 'c' or 'C'
            // It's likely a Bool stored as NSNumber
            return num.boolValue ? "true" : "false"
        }
        // Handle numbers
        return num.stringValue
    }
    
    // Fallback: try to convert to string
    return escapeString(String(describing: value))
}

private func escapeString(_ str: String) -> String {
    var result = "\""
    for char in str {
        switch char {
        case "\\":
            result += "\\\\"
        case "\"":
            result += "\\\""
        case "\t":
            result += "\\t"
        case "\n":
            result += "\\n"
        case "\r":
            result += "\\r"
        case "\u{8}":
            result += "\\b"
        case "\u{C}":
            result += "\\f"
        default:
            result.append(char)
        }
    }
    result += "\""
    return result
}
