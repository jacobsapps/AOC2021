import Foundation

/// Custom error cases
///
public enum PuzzleError: Error {
    case invalidURL
    case invalidBracketCharacter
    case invalidClosingBracket
}

/// Simple helper methods to parse out strings from a text file
///
/// It isn't relevant to the solution or particularly interesting so I relegated it to the sources folder
///
public struct TextFileLoader {
    
    public static func loadData(from file: String) throws -> [String] {
        try loadFile(from: file)
            .split(whereSeparator: \.isNewline)
            .compactMap { String($0) }
    }
    
    private static func loadFile(from fileName: String, ext: String = "txt") throws -> String {
        guard let fileUrl = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            throw PuzzleError.invalidURL
        }
        return try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
    }
}
