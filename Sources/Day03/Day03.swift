//
//  Day03.swift
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
struct Day03: Puzzle {
    typealias Input = Engine
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

struct Engine: Parsable {
    let map: [Coordinate2D: Character]
    var parts: [Coordinate2D: Part]
    var gears: [Gear]

    static func parse(raw: String) throws -> Engine {
        let lines = raw.components(separatedBy: .newlines)
        var map: [Coordinate2D: Character] = [:]
        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() {
                if char == "." {
                    continue
                }
                map[.init(x: x, y: y)] = char
            }
        }
        var parts: [Coordinate2D: Part] = [:]
        for (coordinate, char) in map {
            guard char.isNumber else {
                // Ignore symbols
                continue
            }
            if map[.init(x: coordinate.x - 1, y: coordinate.y)]?.isNumber == true {
                // Ignore parts of numbers
                continue
            }
            let start = coordinate
            var value = char.wholeNumberValue.unsafelyUnwrapped
            var adjacents = coordinate.allNeighbors
            var nextCoordinate = Coordinate2D(x: coordinate.x + 1, y: coordinate.y)
            while let nextValue = map[nextCoordinate], nextValue.isNumber {
                value = value * 10 + nextValue.wholeNumberValue.unsafelyUnwrapped
                adjacents.remove(nextCoordinate)
                adjacents = adjacents.union(nextCoordinate.allNeighbors.subtracting([.init(x: nextCoordinate.x - 1, y: nextCoordinate.y)]))
                nextCoordinate = .init(x: nextCoordinate.x + 1, y: nextCoordinate.y)
            }
            parts[start] = .init(value: value, adjacent: adjacents)
        }
        var gears: [Gear] = []
        for (coordinate, char) in map {
            guard char == "*" else {
                // Ignore non-potential gear
                continue
            }
            var numbers: Set<Coordinate2D> = []
            // For each adjacent, find the beginning of the number
            for adjacent in coordinate.allNeighbors where map[adjacent]?.isNumber == true {
                var start = adjacent
                while map[Coordinate2D(x: start.x - 1, y: start.y)]?.isNumber == true {
                    start = Coordinate2D(x: start.x - 1, y: start.y)
                }
                numbers.insert(start)
            }
            guard numbers.count == 2 else {
                // Not a gear!
                continue
            }
            gears.append(.init(numbers: numbers.map({ parts[$0].unsafelyUnwrapped.value })))
        }
        return .init(map: map, parts: parts, gears: gears)
    }
}

extension Engine {
    struct Part {
        let value: Int
        let adjacent: Set<Coordinate2D>
    }

    struct Gear {
        let numbers: (Int, Int)

        var value: Int {
            numbers.0 * numbers.1
        }

        init(numbers: [Int]) {
            assert(numbers.count == 2)
            self.numbers = (numbers[0], numbers[1])
        }
    }
}

// MARK: - PART 1

extension Day03 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 4361, fromRaw: "467..114..\n...*......\n..35..633.\n......#...\n617*......\n.....+.58.\n..592.....\n......755.\n...$.*....\n.664.598..")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.parts.values
            .filter({ $0.adjacent.contains(where: { input.map[$0] != nil }) })
            .map(\.value)
            .reduce(0, +)
    }
}

// MARK: - PART 2

extension Day03 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 467835, fromRaw: "467..114..\n...*......\n..35..633.\n......#...\n617*......\n.....+.58.\n..592.....\n......755.\n...$.*....\n.664.598..")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.gears
            .map(\.value)
            .reduce(0, +)
    }
}
