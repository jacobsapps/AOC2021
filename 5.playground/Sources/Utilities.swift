import Foundation

/// Custom error cases
///
public enum PuzzleError: Error {
    case invalidURL
    case invalidCoordinate
    case invalidVent
}

/// Simple helper methods to parse out strings from a text file
///
/// It isn't relevant to the solution or particularly interesting so I relegated it to the sources folder
///
public struct TextFileLoader {
    
    public static func ventData() throws -> [String] {
        try loadFile(named: "vents")
            .split(whereSeparator: \.isNewline)
            .compactMap { String($0) }
    }
    
    private static func loadFile(named name: String, ext: String = "txt") throws -> String {
        guard let fileUrl = Bundle.main.url(forResource: name, withExtension: ext) else {
            throw PuzzleError.invalidURL
        }
        return try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
    }
}
