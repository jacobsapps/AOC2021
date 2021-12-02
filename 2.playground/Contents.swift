import Foundation

// MARK: - Types

/// Simple data structure to encode a direction (or aim amount) with a magnitude in that direction
///
enum Direction {
    
    case up(magnitude: Int)
    case down(magnitude: Int)
    case forward(magnitude: Int)
    
    init(from direction: String, _ magnitude: Int) throws {
        switch direction {
        case "up":
            self = .up(magnitude: magnitude)
        case "down":
            self = .down(magnitude: magnitude)
        case "forward":
            self = .forward(magnitude: magnitude)
        default:
            throw PuzzleError.invalidDirection
        }
    }
}

/// Simple data structure to store an aggregate depth and total horizontal distance
///
/// Includes methods to:
/// - increment depth and horizontal values in the coordinates with a direction enum value
/// - calculate the product of distance and depth (for the puzzle solution)
/// - increment depth, horizontal, and aim values for the coordinates with a direction enum value
///
struct Coordinates {
    
    var depth: Int
    var horizontal: Int
    var aim: Int
    
    var product: Int {
        depth * horizontal
    }
    
    init() {
        depth = 0
        horizontal = 0
        aim = 0
    }
    
    mutating func basicAdd(_ direction: Direction) {
        switch direction {
        case .up(let magnitude): depth -= magnitude
        case .down(let magnitude): depth += magnitude
        case .forward(let magnitude): horizontal += magnitude
        }
    }
    
    mutating func aimedAdd(_ direction: Direction) {
        switch direction {
        case .up(let magnitude):
            aim -= magnitude
            
        case .down(let magnitude):
            aim += magnitude
            
        case .forward(let magnitude):
            horizontal += magnitude
            depth += aim * magnitude
        }
    }
}

// MARK: - Extensions

extension String {

    /// Converts a String of the format "direction X" to a Direction
    /// where direction is the direction enum case and X is the distance
    ///
    /// e.g. "up 3" becomes `.up(distance: 3)`
    ///
    /// Returns nil when an invalid direction or distance is used so invalid values can be flatMapped out
    ///
    var direction: Direction? {
        let substrings = split(separator: " ")
        guard let directionString = substrings.first,
              let distanceString = substrings.last,
              let distanceInt = Int(String(distanceString)) else { return nil }
        return try? Direction(from: String(directionString), distanceInt)
    }
}

/// Convert a sequence of Directions into a final Coordinate value
///
extension Sequence where Element == Direction {
    
    var basicCoordinates: Coordinates {
        reduce(into: Coordinates(), {
            $0.basicAdd($1)
        })
    }
    
    var aimedCoordinates: Coordinates {
        reduce(into: Coordinates(), {
            $0.aimedAdd($1)
        })
    }
}

// MARK: - Solutions

/// Part 1
try TextFileLoader(fileName: "directions").strings()
    .compactMap { $0.direction }
    .basicCoordinates
    .product // 1499229

// Part 2
try TextFileLoader(fileName: "directions").strings()
    .compactMap { $0.direction }
    .aimedCoordinates
    .product // 1340836560

