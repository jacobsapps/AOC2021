import Foundation

/// Custom error cases
///
public enum PuzzleError: Error {
    case invalidURL
}

/// Simple helper methods to parse out strings from a text file
///
/// It isn't relevant to the solution or particularly interesting so I relegated it to the sources folder
///
public struct TextFileLoader {
    
    private var fileName: String
    
    public init(fileName: String) {
        self.fileName = fileName
    }
    
    public func data() throws -> [String] {
        try loadFile()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ",")
            .compactMap { String($0) }
    }
    
    private func loadFile(ext: String = "txt") throws -> String {
        guard let fileUrl = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            throw PuzzleError.invalidURL
        }
        return try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
    }
}
