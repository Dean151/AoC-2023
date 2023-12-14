
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
    static let zero = Coordinate2D(x: 0, y: 0)
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

    public func moved(to direction: Direction2D) -> Coordinate2D {
        switch direction {
        case .north:
            return .init(x: x, y: y - 1)
        case .south:
            return .init(x: x, y: y + 1)
        case .west:
            return .init(x: x - 1, y: y)
        case .east:
            return .init(x: x + 1, y: y)
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

public enum Direction2D {
    case north
    case south
    case west
    case east
}
