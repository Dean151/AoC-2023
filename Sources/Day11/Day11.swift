//
//  Day11.swift
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
struct Day11: Puzzle {
    typealias Input = Universe
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example = """
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
"""

struct Universe: Parsable {
    let galaxies: Set<Coordinate2D>
    let expandSize: Int

    init(galaxies: Set<Coordinate2D>, expandSize: Int = 1_000_000) {
        self.galaxies = galaxies
        self.expandSize = expandSize
    }

    func withExpandSize(_ size: Int) -> Universe {
        .init(galaxies: galaxies, expandSize: size)
    }

    func expanded() -> Universe {
        // Find rows and columns to expand
        let xs = galaxies.map(\.x)
        let ys = galaxies.map(\.y)
        let maxX = xs.max().unsafelyUnwrapped
        let maxY = ys.max().unsafelyUnwrapped

        let xToExpand = (0...maxX).filter({ !xs.contains($0) })
        let yToExpand = (0...maxY).filter({ !ys.contains($0) })

        var expandedGalaxies: Set<Coordinate2D> = []
        for galaxy in galaxies {
            expandedGalaxies.insert(.init(
                x: galaxy.x + xToExpand.filter({ $0 < galaxy.x }).count * (expandSize - 1),
                y: galaxy.y + yToExpand.filter({ $0 < galaxy.y }).count * (expandSize - 1))
            )
        }
        return .init(galaxies: expandedGalaxies)
    }

    static func parse(raw: String) throws -> Universe {
        var galaxies: Set<Coordinate2D> = []
        for (y, line) in raw.components(separatedBy: .newlines).enumerated() {
            for (x, char) in line.enumerated() where char == "#" {
                galaxies.insert(.init(x: x, y: y))
            }
        }
        return .init(galaxies: galaxies)
    }
}

// MARK: - PART 1

extension Day11 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 374, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.withExpandSize(2).expanded().galaxies
            .combinations(ofCount: 2)
            .map({ $0[0].mannathanDistance(from: $0[1]) })
            .reduce(0, +)
    }
}

// MARK: - PART 2

extension Day11 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 1030, from: try! transform(raw: example).withExpandSize(10)),
            assert(expectation: 8410, from: try! transform(raw: example).withExpandSize(100))
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.expanded().galaxies
            .combinations(ofCount: 2)
            .map({ $0[0].mannathanDistance(from: $0[1]) })
            .reduce(0, +)
    }
}
