import Foundation

enum EngineeringStrategy {
    
    case human
    case crab
    
    func fuelSpent(from position: Int, to destination: Int) -> Int {
        let n = abs(position - destination)
        switch self {
        case .human:
            return n
            
        case .crab:
            return Int(0.5 * Double(n) * (Double(n) + 1)) // Gauss' summation formula
        }
    }
}

struct Crab: CustomStringConvertible {
    
    var description: String {
        "\(position)"
    }
    
    var position: Int
}

/// The collective noun; i.e. "a cast of crabs"
struct Cast {

    var crabs: [Crab]
    var engineeringStrategy: EngineeringStrategy
    
    var horizontalPositionRange: ClosedRange<Int> {
        let positions = crabs.map { $0.position }
        return (positions.min() ?? 0)...(positions.max() ?? 0)
    }
    
    var minFuelRequired: Int {
        horizontalPositionRange.map {
            totalFuel(for: $0)
        }.min() ?? 0
    }
    
    func totalFuel(for destination: Int) -> Int {
        crabs.reduce(0) {
            $0 + engineeringStrategy.fuelSpent(from: $1.position, to: destination)
        }
    }
}

let testCrabs = try TextFileLoader.loadData(from: "test_crabs")
        .compactMap { Int($0) }
        .map { Crab(position: $0) }
let testCastHuman = Cast(crabs: testCrabs, engineeringStrategy: .human)
let testCastCrab = Cast(crabs: testCrabs, engineeringStrategy: .crab)
    
testCastHuman.minFuelRequired // 37
testCastCrab.minFuelRequired // 168
    
let crabs = try TextFileLoader.loadData(from: "crabs")
        .compactMap { Int($0) }
        .map { Crab(position: $0) }
let castHuman = Cast(crabs: crabs, engineeringStrategy: .human)
let castCrab = Cast(crabs: crabs, engineeringStrategy: .crab)

castHuman.minFuelRequired // 342730
castCrab.minFuelRequired // 92335207

