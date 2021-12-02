import Foundation

// MARK: - Extensions

extension RandomAccessCollection where Element: SignedInteger {
    
    /// Returns the number of times in the collection where the delta between elements is positive
    /// i.e. the number of times when element (n) is greater than element (n+1)
    /// The first index is dropped because the first element [0] is defined as not greater than a non-existent element [-1]
    var countIncreasingIncrements: Int {
        indices
            .dropFirst()
            .map { index in
                self[index] - self[self.index(before: index)]
            }
            .filter { $0 > 0 }
            .count
    }
}

// MARK: - Global variables

/// Lazy variable that returns an array of Int values from the text file containing the data
var sonarData: [Int] = {
    guard let fileUrl = Bundle.main.url(forResource: "sonar", withExtension: "txt"),
          let dataString = try? String(contentsOf: fileUrl, encoding: String.Encoding.utf8) else { return [] }
    return dataString.split(whereSeparator: \.isNewline)
        .map { String($0) }
        .compactMap { Int($0) }
}()

// MARK: - Part 1

sonarData
    .countIncreasingIncrements // 1791

// MARK: - Part 2

/// Since indices is a computed property (it's just O(1) but still more than nothing) I'll store it in a variable to avoid calling it ~6001 times
/// Check out the source code for RandomAccessCollection for the implementation details of `indices`
/// https://github.com/apple/swift/blob/main/stdlib/public/core/RandomAccessCollection.swift
let indices = sonarData.indices

let tripleSums: [Int] = indices
    .compactMap { index in
        guard indices.contains(index),
              indices.contains(index + 1),
              indices.contains(index + 2) else { return nil }
        
        return sonarData[index] + sonarData[index + 1] + sonarData[index + 2]
    }

tripleSums
    .countIncreasingIncrements // 1822
