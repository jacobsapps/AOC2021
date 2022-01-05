import Foundation

/// Enum to represent the type of bracket character used
enum Bracket {
    
    case roundBoi
    case squareBoi
    case curlyBoi
    case sharpBoi
    
    var autocompleteValue: Int {
        switch self {
        case .roundBoi: return 1
        case .squareBoi: return 2
        case .curlyBoi: return 3
        case .sharpBoi: return 4
        }
    }
    
    init?(from string: String) {
        switch string {
        case "(": self = .roundBoi
        case "[": self = .squareBoi
        case "{": self = .curlyBoi
        case "<": self = .sharpBoi
        default: return nil
        }
    }
    
    func canClose(with string: String) -> Bool {
        switch self {
        case .roundBoi: return string == ")"
        case .squareBoi: return string == "]"
        case .curlyBoi: return string == "}"
        case .sharpBoi: return string == ">"
        }
    }
    
    static func illegalCharacterValue(for character: String?) -> Int? {
        switch character {
        case ")": return 3
        case "]": return 57
        case "}": return 1197
        case ">": return 25137
        default: return nil
        }
    }
}

/// Specialised stack that operates using brackets - you can only push brackets and can only pop from the stack with a correct closing bracket.
///
/// The only public method is to "apply" a character, and the rules determine whether it is pushed (for `(, [, {, <`), popped (for `), ], }, >`), or if it fails (where there is no matching brace.
///
struct BracketStack: CustomStringConvertible {
    
    var description: String {
        "\(array)"
    }
    
    private var array = [Bracket]()
    
    init(with string: String = "") {
        string.forEach {
            self.apply(character: String($0))
        }
    }
    
    var isEmpty: Bool {
        array.isEmpty
    }
    
    var count: Int {
        array.count
    }
    
    var peek: Bracket? {
        array.last
    }
    
    mutating func pop() throws -> Bracket? {
        array.popLast()
    }
    
    @discardableResult
    mutating func apply(character: String) -> Int? {
        if let openingBracket = Bracket(from: character) {
            push(openingBracket)
            return nil
        } else {
            guard let _ = try? attemptPop(with: character) else {
                return Bracket.illegalCharacterValue(for: character)
            }
            return nil
        }
    }
    
    private mutating func push(_ bracket: Bracket) {
        array.append(bracket)
    }
    
    private mutating func attemptPop(with character: String) throws -> Bracket? {
        guard let peek = peek else { return nil } // stack is empty
        if peek.canClose(with: character) {
            return array.popLast()
        } else {
            throw PuzzleError.invalidClosingBracket
        }
    }
}

extension Collection where Element == String {
    
    var illegalCharacterTotal: Int {
        reduce(0) {
            var stack = BracketStack()
            let firstIllegalCharacter = $1.first(where: { stack.apply(character: String($0)) != nil })
            return $0 + (Bracket.illegalCharacterValue(for: String(firstIllegalCharacter ?? " ")) ?? 0)
        }
    }
    
    var filteringCorruptedLines: [String] {
        filter {
            var stack = BracketStack()
            return !$0.contains(where: { stack.apply(character: String($0)) != nil })
        }
    }
    
    // Instead of determining the matching braces, we can just pop the remaining stuff off the stack and count the scores.
    var scores: [Int] {
        map {
            var stack = BracketStack(with: $0)
            var score = 0
            while let bracket = try? stack.pop() {
                score = (score * 5) + bracket.autocompleteValue
            }
            return score
        }
    }
}

/// Get the middle value of an unordered collection of integers
extension Collection where Element == Int {
    
    var middleValue: Int {
        sorted()[(count - 1) / 2]
    }
}

// MARK: - Part I
let testNavigation = try TextFileLoader.loadData(from: "test_navigation")
let navigation = try TextFileLoader.loadData(from: "navigation")

print(testNavigation.illegalCharacterTotal) // 26397
print(navigation.illegalCharacterTotal) // 316851

// MARK: - Part II
print(testNavigation.filteringCorruptedLines.scores.middleValue) // 288957
print(navigation.filteringCorruptedLines.scores.middleValue) // 2182912364
