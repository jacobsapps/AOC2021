import Foundation

struct Coordinate: Hashable, CustomStringConvertible {
    
    var description: String {
        "(\(x), \(y))"
    }
    
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    /// Initialized with a string of the format `100,200`
    init(from coordinateString: String) throws {
        let split = coordinateString.split(separator: ",").compactMap { String($0) }
        guard split.indices.contains(0),
              let x = Int(split[0]),
              split.indices.contains(1),
              let y = Int(split[1]) else {
                  throw PuzzleError.invalidCoordinate
              }
        self.x = x
        self.y = y
    }
}

struct Vent: CustomStringConvertible {
    
    var description: String {
        "\(start) -> \(end)\n"
    }
    
    let start: Coordinate
    let end: Coordinate
    
    var allCoordinates: [Coordinate] {
        if isHorizontal {
            let y = start.y
            
            return (min(start.x, end.x)...max(start.x, end.x)).map {
                Coordinate(x: $0, y: y)
            }
            
        } else if isVertical {
            let x = start.x
            return (min(start.y, end.y)...max(start.y, end.y)).map {
                Coordinate(x: x, y: $0)
            }
            
        } else {
            let diff = abs(end.x - start.x)
            return (0...diff).map { Coordinate(x: start.x + (start.x < end.x ? $0 : -$0),
                                               y: start.y + (start.y < end.y ? $0 : -$0)) }
        }
    }
    
    var isStraight: Bool {
        isHorizontal || isVertical
    }

    var isHorizontal: Bool {
        start.y == end.y
    }
    
    var isVertical: Bool {
        start.x == end.x
    }
    
    /// Initialized with a string of the format `100,200 -> 300,400`
    init(from ventString: String) throws {
        let split = ventString.components(separatedBy: " -> ")
        guard split.indices.contains(0),
              split.indices.contains(1) else {
                  throw PuzzleError.invalidVent
              }
        self.start = try Coordinate(from: split[0])
        self.end = try Coordinate(from: split[1])
    }
}

struct Grid {
    
    var contents = [Coordinate: Int]()
    
    init(vents: [Vent]) {
        vents
            .flatMap { $0.allCoordinates }
            .forEach {
                contents[$0] = (contents[$0] ?? 0) + 1
        }
    }
}

let allVents = try TextFileLoader.ventData()
    .map { try Vent(from: $0) }
    
let numberOfOverlapsOfMoreThanTwoStraightGeothermalUnderseaVents = Grid(vents: allVents.filter { $0.isStraight }).contents.values.filter { $0 > 1 }.count
print(numberOfOverlapsOfMoreThanTwoStraightGeothermalUnderseaVents) // 6461

let numberOfOverlapsOfMoreThanTwoGeothermalUnderseaVents = Grid(vents: allVents).contents.values.filter { $0 > 1 }.count
print(numberOfOverlapsOfMoreThanTwoGeothermalUnderseaVents) // 18065
