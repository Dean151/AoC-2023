
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
}
