import Foundation

struct Lanternfish: CustomStringConvertible {
    
    var description: String {
        "\(timer)"
    }
    
    var timer: Int
    
    @discardableResult
    mutating func tick() -> Lanternfish? {
        switch timer {
        case 0:
            timer = 6
            return Lanternfish(timer: 8)
            
        default:
            timer -= 1
            return nil
        }
    }
}

//func simulate(fish: [Lanternfish], days: Int) -> Int {
//    var fish = fish
//    (0..<days).forEach { _ in
//        fish.append(contentsOf: fish.indices.reduce(into: [Lanternfish]()) {
//            $0.append(fish[$1].tick())
//        }.compactMap { $0 })
//    }
//    return fish.count
//}

//func mutatingSimulate(fish: inout [Lanternfish], days: Int) -> Int {
//    (0..<days).forEach { _ in
//        fish.append(contentsOf: fish.indices.reduce(into: [Lanternfish]()) {
//            $0.append(fish[$1].tick())
//        }.compactMap { $0 })
//    }
//}

func miniSimulate(fish: inout [Lanternfish]) {
    fish.append(contentsOf: fish.indices.reduce(into: [Lanternfish]()) {
        $0.append(fish[$1].tick())
    }.compactMap { $0 })
}


var testFish = try TextFileLoader(fileName: "fish_test").data()
    .compactMap { Int ($0) }
    .map { Lanternfish(timer: $0) }
                        
var fish = try TextFileLoader(fileName: "fish").data()
    .compactMap { Int ($0) }
    .map { Lanternfish(timer: $0) }

// MARK: Part I

//simulate(fish: testFish, days: 18) // 26
//simulate(fish: testFish, days: 80) // 5934

//simulate(fish: fish, days: 80) // 380612

// Slightly cleaner version that runs faster on account of mutating a single array rather than holding the value in one function
//(0..<80).forEach {
//    miniSimulate(fish: &fish)
//    print("Day \($0): \(fish.count) fish")
//}

print(fish.count)

// MARK: Part II

struct School {
    
    typealias DaysRemaining = Int
    typealias NumberOfFish = Int
        
    var lanternfish = [DaysRemaining: NumberOfFish]()
    
    init(fish: [Lanternfish]) {
        fish
            .map { $0.timer }
            .forEach {
            self.lanternfish[$0] = (self.lanternfish[$0] ?? 0) + 1
        }
    }
    
    var count: Int {
        lanternfish.values.reduce(0, +)
    }
    
    mutating func tick() {
        var updatedFish = [DaysRemaining: NumberOfFish]()
        print("\n\nLanternfish:")
        print(lanternfish.keys.sorted().compactMap { "\($0): \(lanternfish[$0] ?? 0)" })
        
        lanternfish.keys.sorted().forEach {
            if $0 == 0 {
                updatedFish[8] = lanternfish[0]
                updatedFish[6] = lanternfish[0]
                
            } else {
                let fishFromBreeding = updatedFish[$0 - 1] ?? 0
                let fishFromTimers = lanternfish[$0] ?? 0
                updatedFish[$0 - 1] = fishFromBreeding + fishFromTimers
            }
        }
        lanternfish = updatedFish
    }
}

var school = School(fish: fish)

// Check test result
//(0..<80).forEach {
//    school.tick()
//    print("Day \($0): \(school.count) fish")
//}

(0..<256).forEach {
    school.tick()
    print("Day \($0): \(school.count) fish")
    // 1710166656900
}

// Instead of letting it be exponential, make a dictionary:
// 10 0s,
// 30 1s,
// 20 2s,
// etc. Each cycle, swap around the keys on each (1 to 0, 2 to 1, etc) and append as many 6s and 8s as there are 0s

