//
//  Day10.swift
//  AoC-Swift-Template
//  Forked from https://github.com/Dean151/AoC-Swift-Template
//
//  Created by Thomas DURAND.
//  Follow me on Twitter @deanatoire
//  Check my computing blog on https://www.thomasdurand.fr/
//

import Foundation

import AoC
import Common
import Algorithms

@main
struct Day10: Puzzle {
    typealias Input = Maze
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example1 = """
-L|F7
7S-7|
L|7||
-L-J|
L|-JF
"""


let example2 = """
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
"""

let example3 = """
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
"""

let example3bis = """
..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
..........
"""

let example4 = """
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
"""

let example5 = """
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
"""

struct Maze: Parsable {
    enum Pipe: Character {
        case northSouth = "|"
        case eastWest = "-"
        case northEast = "L"
        case northWest = "J"
        case southWest = "7"
        case southEast = "F"

        func neighbors(from pos: Coordinate2D) -> Set<Coordinate2D> {
            return switch self {
            case .northSouth: [.init(x: pos.x, y: pos.y - 1), .init(x: pos.x, y: pos.y + 1)]
            case .eastWest: [.init(x: pos.x - 1, y: pos.y), .init(x: pos.x + 1, y: pos.y)]
            case .northEast: [.init(x: pos.x, y: pos.y - 1), .init(x: pos.x + 1, y: pos.y)]
            case .northWest: [.init(x: pos.x, y: pos.y - 1), .init(x: pos.x - 1, y: pos.y)]
            case .southWest: [.init(x: pos.x, y: pos.y + 1), .init(x: pos.x - 1, y: pos.y)]
            case .southEast: [.init(x: pos.x, y: pos.y + 1), .init(x: pos.x + 1, y: pos.y)]
            }
        }

        func expand(from pos: Coordinate2D) -> [Coordinate2D: Pipe] {
            switch self {
            case .northSouth:
                return [
                    .init(x: pos.x + 1, y: pos.y): .northSouth,
                    .init(x: pos.x + 1, y: pos.y + 1): .northSouth,
                    .init(x: pos.x + 1, y: pos.y + 2): .northSouth,
                ]
            case .eastWest:
                return [
                    .init(x: pos.x, y: pos.y + 1): .eastWest,
                    .init(x: pos.x + 1, y: pos.y + 1): .eastWest,
                    .init(x: pos.x + 2, y: pos.y + 1): .eastWest,
                ]
            case .northEast:
                return [
                    .init(x: pos.x + 1, y: pos.y): .northSouth,
                    .init(x: pos.x + 1, y: pos.y + 1): .northEast,
                    .init(x: pos.x + 2, y: pos.y + 1): .eastWest,
                ]
            case .northWest:
                return [
                    .init(x: pos.x + 1, y: pos.y): .northSouth,
                    .init(x: pos.x + 1, y: pos.y + 1): .northWest,
                    .init(x: pos.x, y: pos.y + 1): .eastWest,
                ]
            case .southWest:
                return [
                    .init(x: pos.x, y: pos.y + 1): .eastWest,
                    .init(x: pos.x + 1, y: pos.y + 1): .southWest,
                    .init(x: pos.x + 1, y: pos.y + 2): .northSouth,
                ]
            case .southEast:
                return [
                    .init(x: pos.x + 2, y: pos.y + 1): .eastWest,
                    .init(x: pos.x + 1, y: pos.y + 1): .southEast,
                    .init(x: pos.x + 1, y: pos.y + 2): .northSouth,
                ]
            }
        }

        static func from(directions: [Direction2D]) throws -> Pipe {
            guard directions.count == 2 else {
                throw ExecutionError.unsolvable
            }
            return switch (directions[0], directions[1]) {
            case (.north, .south), (.south, .north): .northSouth
            case (.west, .east), (.east, .west): .eastWest
            case (.north, .east), (.east, .north): .northEast
            case (.west, .north), (.north, .west): .northWest
            case (.west, .south), (.south, .west): .southWest
            case (.south, .east), (.east, .south): .southEast
            default: throw ExecutionError.unsolvable
            }
        }
    }

    let start: Coordinate2D
    let pipes: [Coordinate2D: Pipe]
    let loop: Set<Coordinate2D>

    var furthestFromStartDistance: Int {
        loop.count / 2
    }

    var expanded: Maze {
        var expandedPipes: [Coordinate2D: Pipe] = [:]
        var expandedLoop: Set<Coordinate2D> = []
        for coordinate in loop {
            let pipe = pipes[coordinate].unsafelyUnwrapped
            let expandedPipe = pipe.expand(from: .init(x: coordinate.x * 3, y: coordinate.y * 3))
            expandedPipes.merge(expandedPipe, uniquingKeysWith: { a, _ in return a })
            expandedLoop.formUnion(expandedPipe.keys)
        }
        return .init(start: .init(x: start.x * 3, y: start.y * 3), pipes: expandedPipes, loop: expandedLoop)
    }

    var enclosedTiles: Set<Coordinate2D> {
        get throws {
            let expanded = self.expanded
            let expandedEnclosed = try expanded.naiveEnclosedTiles
            let (minX, maxX) = expandedEnclosed.map({ $0.x / 3 }).minAndMax().unsafelyUnwrapped
            let (minY, maxY) = expandedEnclosed.map({ $0.y / 3 }).minAndMax().unsafelyUnwrapped
            var enclosed: Set<Coordinate2D> = []
            for x in minX...maxX {
                for y in minY...maxY {
                    let expandedCenter = Coordinate2D(x: x*3+1, y: y*3+1)
                    guard expandedEnclosed.contains(expandedCenter) else {
                        continue
                    }
                    guard expandedCenter.allNeighbors.allSatisfy({ expandedEnclosed.contains($0) }) else {
                        continue
                    }
                    enclosed.insert(.init(x: x, y: y))
                }
            }
            return enclosed
        }
    }

    var naiveEnclosedTiles: Set<Coordinate2D> {
        get throws {
            let (minX, maxX) = loop.map(\.x).minAndMax().unsafelyUnwrapped
            let (minY, maxY) = loop.map(\.y).minAndMax().unsafelyUnwrapped

            var inside: Set<Coordinate2D> = []
            var outside: Set<Coordinate2D> = []

            for x in minX+1...maxX-1 {
                for y in minY+1...maxY-1 {
                    let current = Coordinate2D(x: x, y: y)
                    if loop.contains(current) || inside.contains(current) || outside.contains(current) {
                        continue
                    }
                    let (found, coordinates) = try findPathOut(limits: (minX...maxX, minY...maxY), from: current)
                    if found {
                        outside.formUnion(coordinates)
                    } else {
                        inside.formUnion(coordinates)
                    }
                }
            }

            return inside
        }
    }

    private func findPathOut(limits: (x: ClosedRange<Int>, y: ClosedRange<Int>), from coordinate: Coordinate2D) throws -> (found: Bool, tranversed: Set<Coordinate2D>) {
        var seen = Set([coordinate])
        var upcoming = Set(coordinate.allNeighbors.subtracting(loop))
        while let current = upcoming.popFirst() {
            if !limits.x.contains(current.x) || !limits.y.contains(current.y) {
                return (true, seen.union(upcoming))
            }
            seen.insert(current)
            upcoming.formUnion(current.allNeighbors.subtracting(loop).subtracting(seen))
        }
        return (false, seen)
    }

    static func parse(raw: String) throws -> Maze {
        var start: Coordinate2D?
        var pipes: [Coordinate2D: Pipe] = [:]
        for (y, line) in raw.components(separatedBy: .newlines).enumerated() {
            for (x, char) in line.enumerated() {
                if char == "." {
                    continue
                }
                if char == "S" {
                    start = .init(x: x, y: y)
                    continue
                }
                guard let pipe = Pipe(rawValue: char) else {
                    throw InputError.unexpectedInput(unrecognized: char.description)
                }
                pipes[.init(x: x, y: y)] = pipe
            }
        }
        guard let start else {
            throw InputError.unexpectedInput(unrecognized: "No start!")
        }
        // Resolve start shape
        let directions = start.adjectiveNeighbors.filter({ pipes[$0]?.neighbors(from: $0).contains(start) == true }).compactMap({ start.direction(to: $0) })
        pipes[start] = try .from(directions: directions)

        // Resolve loop
        var current = start
        var loop = Set([start])
        var next = pipes[start].unsafelyUnwrapped.neighbors(from: start).first(where: { $0 != current }).unsafelyUnwrapped
        while true {
            if loop.contains(next) {
                break
            }
            loop.insert(next)
            let upcoming = pipes[next].unsafelyUnwrapped.neighbors(from: next).first(where: { $0 != current }).unsafelyUnwrapped
            current = next
            next = upcoming
        }
        return .init(start: start, pipes: pipes, loop: loop)
    }
}

// MARK: - PART 1

extension Day10 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 4, fromRaw: example1),
            assert(expectation: 8, fromRaw: example2)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.furthestFromStartDistance
    }
}

// MARK: - PART 2

extension Day10 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 4, fromRaw: example3),
            assert(expectation: 4, fromRaw: example3bis),
            assert(expectation: 8, fromRaw: example4),
            assert(expectation: 10, fromRaw: example5)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        try input.enclosedTiles.count
    }
}
