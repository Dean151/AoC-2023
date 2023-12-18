
// MARK: - Coordinate

public struct Coordinate2D: Hashable, Equatable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

extension Coordinate2D {
    public static let zero = Coordinate2D(x: 0, y: 0)
}

extension Coordinate2D: CustomStringConvertible {
    public var description: String {
        "(\(x),\(y))"
    }
}

extension Coordinate2D {
    public var adjectiveNeighbors: Set<Coordinate2D> {
        [
            .init(x: x - 1, y: y),
            .init(x: x, y: y - 1),
            .init(x: x + 1, y: y),
            .init(x: x, y: y + 1)
        ]
    }

    public var diagonalNeighbors: Set<Coordinate2D> {
        [
            .init(x: x - 1, y: y - 1),
            .init(x: x - 1, y: y + 1),
            .init(x: x + 1, y: y - 1),
            .init(x: x + 1, y: y + 1)
        ]
    }

    public var allNeighbors: Set<Coordinate2D> {
        adjectiveNeighbors.union(diagonalNeighbors)
    }

    public func outOfBounds(width: Int, height: Int) -> Bool {
        !(0..<width).contains(x) || !(0..<height).contains(y)
    }

    public func moved(along direction: Direction2D, distance: Int = 1) -> Coordinate2D {
        switch direction {
        case .north:
            return .init(x: x, y: y - distance)
        case .south:
            return .init(x: x, y: y + distance)
        case .west:
            return .init(x: x - distance, y: y)
        case .east:
            return .init(x: x + distance, y: y)
        }
    }

    public func direction(to other: Coordinate2D) -> Direction2D? {
        if self == other {
            return nil
        }
        if x == other.x {
            return y < other.y ? .south : .north
        }
        if y == other.y {
            return x < other.x ? .east : .west
        }
        return nil
    }

    public func mannathanDistance(from other: Coordinate2D) -> Int {
        abs(other.x - x) + abs(other.y - y)
    }
}


// MARK: - Direction

public enum Direction2D: CaseIterable, CustomStringConvertible {
    case north
    case south
    case west
    case east

    public var description: String {
        switch self {
        case .north:
            return "^"
        case .south:
            return "v"
        case .west:
            return "<"
        case .east:
            return ">"
        }
    }

    public var opposite: Self {
        switch self {
        case .north:
            return .south
        case .south:
            return .north
        case .west:
            return .east
        case .east:
            return .west
        }
    }

    public var orthogonals: (right: Self, left: Self) {
        switch self {
        case .north:
            return (.east, .west)
        case .south:
            return (.west, .east)
        case .west:
            return (.north, .south)
        case .east:
            return (.south, .north)
        }
    }
}
