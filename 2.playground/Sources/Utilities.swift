import Foundation

/// Custom error cases
/// 
public enum PuzzleError: Error {
    case invalidURL
    case invalidDirection
    case invalidDistance
}

/// Simple struct to parse out strings from a text file
///
/// It isn't relevant to the solution or particularly interesting so I relegated it to the sources folder
///
public struct TextFileLoader {
    
    let fileName: String
    let fileExtension: String
    
    public init(fileName: String, fileExtension: String = "txt") {
        self.fileName = fileName
        self.fileExtension = fileExtension
    }
    
    public func strings() throws -> [String] {
        try parseTextFile()
    }

    private func parseTextFile() throws -> [String] {
        try loadTextFile()
            .split(whereSeparator: \.isNewline)
            .map { String($0) }
    }
    
    private func loadTextFile() throws -> String {
        guard let fileUrl = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            throw PuzzleError.invalidURL
        }
        return try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
    }
}
