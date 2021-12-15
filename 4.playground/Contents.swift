import Foundation

/// Data structure to store numbers bingo cards, and operate on and query the state of the numbers
struct BingoCard: CustomStringConvertible {
    
    private let sideLength: Int
    private var contents: [BingoNumber] {
        didSet {
            rows = createRows(for: contents)
            columns = createColumns(for: contents)
        }
    }
    private var rows: [[BingoNumber]] = []
    private var columns: [[BingoNumber]] = []
    var bingoOrdinal: Int?
    
    var description: String {
        rows.reduce("") {
            let row = $1.map { $0.description + " " }.flatMap { $0 }
            return $0 + row + "\n"
        }
    }
    
    var bingo: Bool {
        [rows, columns]
            .flatMap { $0 }
            .contains(where: {
                $0.allSatisfy { $0.marked }
            })
    }
    
    var highestScoreOrdinal: Int {
        contents.compactMap { $0.ordinal }.max() ?? 0
    }
    
    var finalScore: Int {
        let sumOfUnmarkedNumbers = contents
            .filter { !$0.marked }.reduce(0) { $0 + $1.number }
        let lastNumberCalled = contents
            .filter { $0.marked }
            .sorted(by: { ($0.ordinal ?? 0) > ($1.ordinal ?? 0) }).first?.number ?? 0
        return sumOfUnmarkedNumbers * lastNumberCalled
    }

    init(sideLength: Int, numbers: [Int]) {
        self.sideLength = sideLength
        contents = numbers.map { BingoNumber(number: $0) }
    }
         
    mutating func mark(number: Int) {
        guard let numberIndex = contents.firstIndex(where: { $0.number == number }) else { return }
        contents[numberIndex].mark(ordinal: highestScoreOrdinal + 1)
    }

    private func createRows(for contents: [BingoNumber]) -> [[BingoNumber]] {
        (0..<sideLength)
            .map { sideNum in
                let rowLowerBound = sideLength * sideNum
                let rowUpperBound = sideLength * (sideNum + 1)
                return Array(contents[rowLowerBound..<rowUpperBound])
        }
    }

    private func createColumns(for contents: [BingoNumber]) -> [[BingoNumber]] {
        (0..<sideLength)
            .map { sideNum in
                contents.enumerated().compactMap { offset, element in
                    if offset % sideLength == sideNum {
                        return element
                    } else { return nil }
                }
            }
    }
}

/// Data structure to store the number on bingo cards; whether they are marked; and the order in which they were marked
struct BingoNumber: CustomStringConvertible {
    
    let number: Int
    private(set) var marked: Bool = false
    private(set) var ordinal: Int? = nil
    
    var description: String {
        "\(number)\(marked ? "*" : " ")"
    }
    
    mutating func mark(ordinal: Int) {
        marked = true
        self.ordinal = ordinal
    }
}

// MARK: - Part I

var bingoCards1 = try TextFileLoader(fileName: "bingoCards")
    .bingoCardData()
    .map { BingoCard(sideLength: 5, numbers: $0) }

let nums = try TextFileLoader(fileName: "bingoNumbers")
    .bingoNumbers()

nums.forEach { bingoNumber in
    guard bingoCards1.allSatisfy({ !$0.bingo }) else { return }
    bingoCards1.enumerated().forEach {
        bingoCards1[$0.offset].mark(number: bingoNumber)
    }
}

let winningBingoScore = bingoCards1.first(where: { $0.bingo })?.finalScore // 34506
print(winningBingoScore)

// MARK: - Part II

var bingoCards2 = try TextFileLoader(fileName: "bingoCards")
    .bingoCardData()
    .map { BingoCard(sideLength: 5, numbers: $0) }

/// Adjust algorithm to make sure all cards hit Bingo
nums.forEach { bingoNumber in
    guard !bingoCards2.allSatisfy({ $0.bingo }) else { return }
    bingoCards2.enumerated().forEach {
        guard $0.element.bingoOrdinal == nil else { return }
        bingoCards2[$0.offset].mark(number: bingoNumber)
        if bingoCards2[$0.offset].bingo {
            let nextOrdinal = bingoCards2.compactMap { $0.bingoOrdinal }.count + 1
            bingoCards2[$0.offset].bingoOrdinal = nextOrdinal
        }
    }
}

let firstBingoScore = bingoCards2.first(where: { $0.bingoOrdinal == 1 })?.finalScore // 34506
print(firstBingoScore)

let lastBingoScore = bingoCards2.first(where: { $0.bingoOrdinal == bingoCards2.count })?.finalScore // 7686
print(lastBingoScore)
