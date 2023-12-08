//
//  Day08.swift
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
struct Day08: Puzzle {
    typealias Input = Desert
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example1 = """
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
"""

let example2 = """
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
"""

let example3 = """
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
"""

struct Desert: Parsable {
    enum Direction: Character {
        case left = "L"
        case right = "R"
    }

    let directions: [Direction]
    let nodes: [String: (left: String, right: String)]

    var numberOfSteps: Int {
        get throws {
            let count = directions.count
            var current = "AAA"
            var step = 0
            while true {
                if current == "ZZZ" {
                    break
                }
                guard let (left, right) = nodes[current] else {
                    throw ExecutionError.unsolvable
                }
                switch directions[step % count] {
                case .left:
                    current = left
                case .right:
                    current = right
                }
                step += 1
            }
            return step
        }
    }

    var simultaneousNumberOfSteps: Int {
        get throws {
            let count = directions.count
            let starts = nodes.keys.filter { $0.hasSuffix("A") }
            func findLoop(from start: String) throws -> Int {
                var current = start
                var step = 0
                while true {
                    if current.hasSuffix("Z") {
                        return step
                    }
                    guard let (left, right) = nodes[current] else {
                        throw ExecutionError.unsolvable
                    }
                    switch directions[step % count] {
                    case .left:
                        current = left
                    case .right:
                        current = right
                    }
                    step += 1
                }
            }
            let loops = try starts.map { start in
                try findLoop(from: start)
            }

            return leastCommonMultiple(loops)
        }
    }

    static func parse(raw: String) throws -> Desert {
        let components = raw.components(separatedBy: "\n\n")
        guard components.count == 2 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        let directions = components[0].compactMap(Direction.init)
        var nodes: [String: (left: String, right: String)] = [:]
        let regex = #/([A-Z0-9]{3}) = \(([A-Z0-9]{3}), ([A-Z0-9]{3})\)/#
        for line in components[1].components(separatedBy: .newlines) {
            guard let match = line.wholeMatch(of: regex) else {
                throw InputError.unexpectedInput(unrecognized: line)
            }
            nodes[String(match.output.1)] = (String(match.output.2), String(match.output.3))
        }
        return Desert(directions: directions, nodes: nodes)
    }
}

// MARK: - PART 1

extension Day08 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 2, fromRaw: example1),
            assert(expectation: 6, fromRaw: example2)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        try input.numberOfSteps
    }
}

// MARK: - PART 2

extension Day08 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 6, fromRaw: example3)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        try input.simultaneousNumberOfSteps
    }
}
