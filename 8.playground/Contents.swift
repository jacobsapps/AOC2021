import Foundation

/// `Rules`
///
/// - 0 is the only 6-digit number with no other special rules
/// - 1 is the only 2-digit number
/// - 2 is formed of 5-digits with no other special rules
/// - 3 is the only 5-digit number which shares both of 1's digits
/// - 4 is is the only 4-digit number
/// - 5 is the only 5-digit number that with which 9 shares all its digits
/// - 6 is the only 6-digit number which does NOT share both of 1's digits
/// - 7 is the only 3-digit number
/// - 8 is the only 7-digit number
/// - 9 is the only 6-digit number which shares all of 4's digits
///
enum Digit: Int {
    
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    
    init?(string: String) {
        switch string.count {
        case 2: self = .one
        case 4: self = .four
        case 3: self = .seven
        case 7: self = .eight
        default: return nil
        }
    }
    
    init?(string: String, code: [Int: String]) {
        if string.count == 5 {
            if string.containsAllCharacters(in: code[1]) { self = .three
            } else if code[9]?.containsAllCharacters(in: string) == true { self = .five
            } else { if code[9] == nil { return nil } else { self = .two } }
            
        } else if string.count == 6 {
            if !string.containsAllCharacters(in: code[1]) { self = .six
            } else if string.containsAllCharacters(in: code[4]) { self = .nine
            } else { self = .zero }
            
        } else { return nil }
    }
}

struct Decoding: CustomStringConvertible {
    
    var description: String {
        "\(display) | \(output)\n"
    }
    
    private let display: [String]
    private let output: [String]
    
    private var code = [Int: String]()
    
    var decodedOutput: Int?
    
    init?(string: String) {
        let split = string.split(separator: "|")
        guard let display = split.first?.split(separator: " "),
              let output = split.last?.split(separator: " ") else { return nil }
        self.display = display.map { String($0) }
        self.output = output.map { String($0) }
        decode()
    }
    
    private mutating func decode() {
        display
            .forEach {
                if let digit = Digit(string: $0) {
                    code[digit.rawValue] = String($0.sorted())
                }
            }

        display.forEach {
            if let digit = Digit(string: $0, code: code) {
                code[digit.rawValue] = String($0.sorted())
            }
        }
        
        display.forEach {
            if let digit = Digit(string: $0, code: code) {
                code[digit.rawValue] = String($0.sorted())
            }
        }
        print(code.sorted(by: { $0.key < $1.key }))
        
        decodedOutput = displayedDigit(from: output, code: code)
    }
    
    func displayedDigit(from output: [String], code: [Int: String]) -> Int {
        let flippedCode = swapKeyValues(of: code)
        return output.reversed().enumerated().reduce(0) {
            print("Code: ", $1.element)
            let digit = flippedCode[String($1.element.sorted())] ?? 0
            print("Digit: ", digit)
            let base10Mulitplier = Int(pow(10.0, Double($1.offset)))
            print("Base 10 mult: ", base10Mulitplier)
            let answer = $0 + (digit * base10Mulitplier)
            print("Answer: ", answer)
            print()
            print()
            return answer
        }
    }
    
    func swapKeyValues<T, U>(of dict: [T : U]) -> [U: T] {
        let arrKeys = Array(dict.keys)
        let arrValues = Array(dict.values)
        var newDict = [U: T]()
        for (i, n) in arrValues.enumerated() {
            newDict[n] = arrKeys[i]
        }
        return newDict
    }
}

extension String {
    
    func containsAllCharacters(in string: String?) -> Bool {
        guard let string = string else { return false }
        let characterSet = Set(Array(self))
        return Array(string).allSatisfy { characterSet.contains($0) }
    }
}

// MARK: - Part I

let testData = try TextFileLoader.loadData(from: "test_digits")

let data = try TextFileLoader.loadData(from: "digits")

let digits = data
    .compactMap { $0.split(separator: "|").last?.split(separator: " ") }
    .flatMap { $0 }
    .compactMap { Digit(string: String($0)) }

print(digits)
print(digits.count)

// MARK: - Part II

let testData2 = try TextFileLoader.loadData(from: "test_digits_2")

print(testData2.compactMap { Decoding(string: $0)?.decodedOutput }.reduce(0, +))
print(testData.compactMap { Decoding(string: $0)?.decodedOutput }.reduce(0, +))
print(data.compactMap { Decoding(string: $0)?.decodedOutput }.reduce(0, +))
