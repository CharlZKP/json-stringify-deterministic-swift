import Foundation
import JSONStringifyDeterministic

// Command line tool for testing JSONStringifyDeterministic

func printUsage() {
    print("Usage: JSONStringifyDeterministic <file.json> [--space <spaces|tabs>]")
    print("")
    print("Arguments:")
    print("  file.json    Path to JSON file to stringify")
    print("  --space       Enable pretty printing with specified spacing")
    print("                Use '2' for 2 spaces, '4' for 4 spaces, or 'tab' for tabs")
    print("")
    print("Example:")
    print("  JSONStringifyDeterministic test.json")
    print("  JSONStringifyDeterministic test.json --space 2")
}

func parseSpaceArgument(_ arg: String) -> String? {
    switch arg.lowercased() {
    case "tab", "tabs", "\\t":
        return "\t"
    case let num where Int(num) != nil:
        return String(repeating: " ", count: Int(num)!)
    default:
        return nil
    }
}

let arguments = CommandLine.arguments

guard arguments.count >= 2 else {
    printUsage()
    exit(1)
}

let filePath = arguments[1]
var space: String? = nil

// Parse optional arguments
var i = 2
while i < arguments.count {
    switch arguments[i] {
    case "--space":
        guard i + 1 < arguments.count else {
            print("Error: --space requires a value")
            printUsage()
            exit(1)
        }
        space = parseSpaceArgument(arguments[i + 1])
        if space == nil {
            print("Error: Invalid space value '\(arguments[i + 1])'")
            printUsage()
            exit(1)
        }
        i += 2
    default:
        print("Error: Unknown argument '\(arguments[i])'")
        printUsage()
        exit(1)
    }
}

// Read and parse JSON file
guard let data = FileManager.default.contents(atPath: filePath),
      let content = String(data: data, encoding: .utf8) else {
    print("Error: Failed to read file '\(filePath)'")
    exit(1)
}

guard let jsonData = content.data(using: .utf8),
      let obj = try? JSONSerialization.jsonObject(with: jsonData) else {
    print("Error: Failed to parse JSON in '\(filePath)'")
    exit(1)
}

// Stringify with options
let options = Options(space: space)
let result = stringify(obj, options)

print(result)
