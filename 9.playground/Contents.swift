import Foundation
import Darwin

struct Grid: CustomStringConvertible {
    
    var description: String {
        "\(elements)"
    }
    var elements: [Element]
    var elementsDict = [Coordinate: Element]()
    var lowPointDict = [Coordinate: Element]()
    
    var maxX: Int
    var maxY: Int
    
    init(elements: [Element]) {
        self.elements = elements
        maxX = elements.map { $0.coordinate.x }.max() ?? 0
        maxY = elements.map { $0.coordinate.y }.max() ?? 0
        elements.forEach {
            elementsDict[$0.coordinate] = $0
        }
    }
    
    mutating func cumRiskLevel() -> Int {
        elements.reduce(0) { (cum, element) in
            let adjacents = element.coordinate.adjacents(maxX: maxX, maxY: maxY)
            if adjacents.allSatisfy({
                (self[$0]?.value ?? 0) > element.value
            }) {
                lowPointDict[element.coordinate] = element
                return cum + (element.value + 1)
            } else {
                return cum
            }
        }
    }
    
    subscript(coordinate: Coordinate) -> Element? {
        get {
            if let element = elementsDict[coordinate] {
                return element
            } else { return nil }
        }
    }
    
    var basinSizes: [Int] {
        lowPointDict.values.map {
            basinSize(from: $0)
        }
    }
    
    private func basinSize(from element: Element) -> Int {
        var basinSet = Set<Coordinate>()
        basinSet.insert(element.coordinate)
        var basinSize = basinSet.count
        var basinSizeStable = false
        
        while !basinSizeStable {
            basinSet.forEach {
                let adjacents = $0.adjacents(maxX: maxX, maxY: maxY, existing: basinSet)
                adjacents.forEach {
                    if elementsDict[$0]?.value != 9 {
                        basinSet.insert($0)
                    }
                }
            }
            let newCount = basinSet.count
            if newCount != basinSize {
                basinSize = newCount
            } else {
                basinSizeStable = true
            }
        }
        return basinSize
    }
}

struct Element: CustomStringConvertible {
    
    var coordinate: Coordinate
    var value: Int = -1
    
    var description: String {
        "\(value)"
    }
}

struct Coordinate: Hashable, Equatable {
    
    var x: Int
    var y: Int
    
    static func +(lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        Coordinate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    func isValid(maxX: Int, maxY: Int) -> Bool {
        x >= 0
        && y >= 0
        && x <= maxX
        && y <= maxY
    }
    
    func adjacents(maxX: Int, maxY: Int, existing: Set<Coordinate> = Set<Coordinate>()) -> [Coordinate] {
        [
            Coordinate(x: -1, y: 0),
            Coordinate(x: 1, y: 0),
            Coordinate(x: 0, y: -1),
            Coordinate(x: 0, y: 1)
        ].compactMap {
            let adjacent = self + $0
            if !adjacent.isValid(maxX: maxX, maxY: maxY) { return nil }
            if existing.contains(adjacent) { return nil }
            else { return adjacent }
        }
    }
}

let testHeatmapElements = try TextFileLoader.loadData(from: "test_heatmap")
    .enumerated()
    .flatMap { rowOffset, rowElement in
        Array(rowElement).enumerated().compactMap { columnOffset, value in
            Element(coordinate: Coordinate(x: rowOffset, y: columnOffset), value: Int(String(value)) ?? -1)
        }
    }

// MARK: - Part I

var testHeatmap = Grid(elements: testHeatmapElements)
print(testHeatmap.cumRiskLevel()) // 15

let heatmapElements = try TextFileLoader.loadData(from: "heatmap")
    .enumerated()
    .flatMap { rowOffset, rowElement in
        Array(rowElement).enumerated().compactMap { columnOffset, value in
            Element(coordinate: Coordinate(x: rowOffset, y: columnOffset), value: Int(String(value)) ?? -1)
        }
    }
 
var heatmap = Grid(elements: heatmapElements)
print(heatmap.cumRiskLevel()) // 468


// MARK: - Part II
print(testHeatmap.basinSizes.sorted(by: >)[0..<3].reduce(1, *)) // 1134
print(heatmap.basinSizes.sorted(by: >)[0..<3].reduce(1, *)) // 1280496
