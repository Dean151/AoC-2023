//
//  Day18.swift
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
struct Day18: Puzzle {
    typealias Input = [Instruction]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example = """
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
"""

struct Instruction: Parsable {
    let direction: Direction2D
    let meters: Int
    let color: String

    var fixed: Instruction {
        get throws {
            let direction: Direction2D
            switch color.last.unsafelyUnwrapped {
            case "0":
                direction = .east
            case "1":
                direction = .south
            case "2":
                direction = .west
            case "3":
                direction = .north
            default:
                throw InputError.unexpectedInput(unrecognized: color)
            }
            guard let distance = Int(color.prefix(5), radix: 16) else {
                throw InputError.unexpectedInput(unrecognized: color)
            }
            return .init(direction: direction, meters: distance, color: "")
        }
    }

    static func parse(raw: String) throws -> Instruction {
        let regex = #/(U|D|L|R) ([0-9]+) \(#([0-9a-f]{6})\)/#
        guard let match = try regex.wholeMatch(in: raw) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        let direction: Direction2D
        switch match.output.1 {
        case "U":
            direction = .north
        case "D":
            direction = .south
        case "L":
            direction = .west
        case "R":
            direction = .east
        default:
            throw InputError.unexpectedInput(unrecognized: raw)
        }

        guard let meters = Int(match.output.2) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }

        return .init(direction: direction, meters: meters, color: String(match.output.3))
    }
}

struct Lagoon {
    let corners: [Coordinate2D]
    let volume: Int

    init(instructions: [Instruction]) {
        var current: Coordinate2D = .zero
        var corners: [Coordinate2D] = [current]
        var perimeter: Int = 0
        // Resolve the corners
        for instruction in instructions {
            perimeter += instruction.meters
            current = current.moved(to: instruction.direction, distance: instruction.meters)
            corners.append(current)
        }
        self.corners = corners
        // Now, resolve the interior points using Shoelace formula
        var carry = 0
        for window in corners.windows(ofCount: 2) {
            let a = window.first.unsafelyUnwrapped
            let b = window.last.unsafelyUnwrapped
            carry += a.x * b.y - b.x * a.y
        }
        // And use Pick theorem to get the area
        self.volume = (carry / 2) + (perimeter / 2) + 1
    }
}

// MARK: - PART 1

extension Day18 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 62, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let lagoon = Lagoon(instructions: input)
        return lagoon.volume
    }
}

// MARK: - PART 2

extension Day18 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 952408144115, fromRaw: example)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let lagoon = try Lagoon(instructions: input.map { try $0.fixed })
        return lagoon.volume
    }
}
