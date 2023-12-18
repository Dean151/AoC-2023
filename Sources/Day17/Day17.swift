//
//  Day17.swift
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

@main
struct Day17: Puzzle {
    typealias Input = City
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example = """
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
"""

let example2 = """
111111111111
999999999991
999999999991
999999999991
999999999991
"""

struct City: Parsable {
    let width: Int
    let height: Int
    let blocks: [Coordinate2D: Int]

    struct Path: Hashable {
        let position: Coordinate2D
        let direction: Direction2D
        let straight: Int
    }

    func findPath(allowedStraights: ClosedRange<Int>) throws -> Int {
        let start = Path(position: .zero, direction: .east, straight: 0)
        let finish = Coordinate2D(x: width-1, y: height-1)
        var visited: Set<Path> = []
        var toVisit: [Path: (cost: Int, heuristic: Int)] = [start: (0, 0)]
        while let current = toVisit.min(by: { $0.value.heuristic < $1.value.heuristic }) {
            if current.key.position == finish && current.key.straight >= allowedStraights.lowerBound {
                return current.value.cost
            }
            toVisit.removeValue(forKey: current.key)
            var directions = Set(Direction2D.allCases)
            directions.remove(current.key.direction.opposite)
            if current.key.straight != 0 {
                if current.key.straight < allowedStraights.lowerBound {
                    let orthogonals = current.key.direction.orthogonals
                    directions.remove(orthogonals.right)
                    directions.remove(orthogonals.left)
                } else if current.key.straight >= allowedStraights.upperBound {
                    directions.remove(current.key.direction)
                }
            }
            for direction in directions {
                let next = current.key.position.moved(along: direction)
                if next.outOfBounds(width: width, height: height) {
                    continue
                }
                let cost = current.value.cost + blocks[next].unsafelyUnwrapped
                let straight = current.key.direction == direction ? current.key.straight + 1 : 1
                let path = Path(position: next, direction: direction, straight: straight)
                if visited.contains(path) || (toVisit[path]?.cost ?? .max) < cost {
                    continue
                }
                let heuristic = cost + finish.mannathanDistance(from: next)
                toVisit[path] = (cost, heuristic)
            }
            visited.insert(current.key)
        }
        throw ExecutionError.unsolvable
    }

    static func parse(raw: String) throws -> City {
        let lines = raw.components(separatedBy: .newlines)
        let width = lines[0].count
        let height = lines.count
        var blocks: [Coordinate2D: Int] = [:]
        for (y,line) in lines.enumerated() {
            for (x,char) in line.enumerated() {
                guard let value = Int(String(char)) else {
                    continue
                }
                blocks[.init(x: x, y: y)] = value
            }
        }
        return .init(width: width, height: height, blocks: blocks)
    }
}

// MARK: - PART 1

extension Day17 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 102, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        return try input.findPath(allowedStraights: 1...3)
    }
}

// MARK: - PART 2

extension Day17 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 94, fromRaw: example),
            assert(expectation: 71, fromRaw: example2)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        return try input.findPath(allowedStraights: 4...10)
    }
}
