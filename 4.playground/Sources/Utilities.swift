import Foundation

/// Custom error cases
///
public enum PuzzleError: Error {
    case invalidURL
    case invalidNumber
    case invalidBingoCard
    case arrayZeroLengthError
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
    
    public func bingoCardData() throws -> [[Int]] {
        try loadTextFile()
            .components(separatedBy: "\n\n") // split bingo cards by double-newline
            .map {
                do {
                    return try $0.split(whereSeparator: \.isWhitespace)
                        .map {
                            let trimmedString = String($0).trimmingCharacters(in: .whitespacesAndNewlines)
                            guard let int = Int(trimmedString) else {
                                throw PuzzleError.invalidNumber
                            }
                            return int
                        }

                } catch {
                    throw PuzzleError.invalidBingoCard
                }
            }
    }

    public func bingoNumbers() throws -> [Int] {
        try loadTextFile()
            .split(separator: ",")
            .map {
                let trimmedString = String($0).trimmingCharacters(in: .whitespacesAndNewlines)
                guard let int = Int(trimmedString) else {
                    throw PuzzleError.invalidNumber
                }
                return int
            }
    }
    
    private func loadTextFile() throws -> String {
        guard let fileUrl = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            throw PuzzleError.invalidURL
        }
        return try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
    }
}
