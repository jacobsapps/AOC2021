import Foundation

extension Sequence where Element == String {
    
    /// Reduce the sequence into a dictionary of the sum of each bit position
    /// The reversed() operation is used to convert the binary number from big-endian
    /// to little-endian to make calculating a number using powers of 2 more intuituve
    //    var sumsDictionary: [Int: Int] {
    //        print(self)
    //        return reduce(into: [Int: Int]()) { sumsDict
    //            print(sumsDict)
    //            return $1
    //                .reversed()
    //                .enumerated()
    //                .forEach { bit in
    //                    sumsDict.put(String(bit.element), in: bit.offset)
    //                }
    //        }
    //    }
    
    /// Iterate through the elements of the sequence
    /// Calculate the sum of each Nth digit in the
    func sum(nth n: Int) -> Int {
        reduce(into: 0) {
            guard let number = String(Array($1)[n]).binaryDigit else { return }
            $0 += number
        }
    }
    
    /// Return only the arrays where the nth digit matches the digit passed in
    func filtering(nth n: Int, for digit: String) -> Array<Element> {
        filter { $0.map { String($0) }[n] == digit }
    }
}



extension String {
    
    var binaryDigit: Int? {
        switch self {
        case "0": return -1
        case "1": return 1
        default: return nil
        }
    }
    
    /// Get the base-10 number from a sequence of binary digits
    var binaryNumber: Double {
        map { String($0) }
        .reversed()
        .enumerated()
        .reduce(into: 0.0) {
            print("reducing!")
            print($0)
            print($1)
            let increment = ($1.element == "1") ? pow(2.0, Double($1.offset)) : 0
            $0 += increment
        }
    }
}

extension Int {
    
    func adding(binaryDigit: String) throws -> Int {
        switch binaryDigit {
        case "0": return self - 1
        case "1": return self + 1
        default: throw PuzzleError.invalidDigit
        }
    }
}

extension Array where Element == String {
    
    func reading(isReadingMostCommonBit: Bool) throws -> Int {
        guard count > 0 else { throw PuzzleError.arrayZeroLengthError }
        let firstElement = self[0].map { String($0) }
        let digitIndices = firstElement.indices
        var copy = self
        digitIndices.forEach { index in
            if copy.count > 1 {
                let sum = copy.sum(nth: index)
                if isReadingMostCommonBit {
                    copy = copy.filtering(nth: index, for: (sum >= 0) ? "1" : "0") // get the most common bit (use 1 if they're equal)
                    
                } else {
                    copy = copy.filtering(nth: index, for: (sum >= 0) ? "0" : "1") // get the least common bit (use 0 if they're equal)
                }
            }
        }
        return Int(copy[0].binaryNumber)
    }
}


// Key: nth place in the string
// Value: positive or negative depending on whether 0 or 1 is more common
var sumsDict = [Int: Int]()

extension Dictionary where Key == Int, Value == Int {
    
    mutating func put(_ value: String, in key: Int) { // throws {
        if self[key] == nil,
           let digit = value.binaryDigit {
            self[key] = digit
            
        } else {
            self[key] = try? self[key]?.adding(binaryDigit: value)
        }
    }
}

// MARK: - Part I
let powerData = try TextFileLoader(fileName: "power").strings()
    .forEach {
        $0
            .reversed() // make the binary number little-endian to make the power expansion more intuitive
            .enumerated()
            .forEach {
                sumsDict.put(String($0.element), in: $0.offset)
            }
    }

var gamma = 0
var maxKey = 0

for (key, value) in sumsDict {
    if value > 0 {
        gamma += Int(pow(2.0, Double(key)))
    }
    if key > maxKey {
        maxKey = key
    }
}

gamma // 2277
let epsilon = Int(pow(2.0, Double(maxKey + 1))) - gamma - 1
epsilon // 1818
let powerReading = gamma * epsilon // 4139586


// MARK: - Part II
let lifeSupportData = try TextFileLoader(fileName: "power").strings()

do {
    let o2Level = try lifeSupportData.reading(isReadingMostCommonBit: true)
    let co2Level = try lifeSupportData.reading(isReadingMostCommonBit: false)
    let lifeSupportReading = o2Level * co2Level // 1800151
}



