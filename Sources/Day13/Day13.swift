//
//  Day13.swift
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
struct Day13: Puzzle {
    typealias Input = [Pattern]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static var componentsSeparator: InputSeparator {
        .string(string: "\n\n")
    }
}

let example = """
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
"""

struct Pattern: Parsable, CustomStringConvertible {
    enum Case: Character {
        case rock = "#"
        case ash = "."
    }
    enum Reflection {
        case horizontal(row: Int)
        case vertical(column: Int)
    }

    let width: Int
    let height: Int
    let cases: [Coordinate2D: Case]
    var reflection: Reflection
    var smudgeReflection: Reflection?

    var description: String {
        var description = ""
        for y in 0..<height {
            description += String(cases.filter({ $0.key.y == y }).sorted(by: \.key.x).map(\.value.rawValue))
            description += "\n"
        }
        return description
    }

    static func parse(raw: String) throws -> Pattern {
        let lines = raw.components(separatedBy: .newlines)
        let height = lines.count
        let width = lines[0].count
        var cases: [Coordinate2D: Case] = [:]
        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() {
                cases[.init(x: x, y: y)] = Case(rawValue: char).unsafelyUnwrapped
            }
        }
        let reflection = try resolveReflection(width: width, height: height, cases: cases)
        let smudge = try? resolveReflection(width: width, height: height, cases: cases, ignoring: reflection)
        return .init(width: width, height: height, cases: cases, reflection: reflection, smudgeReflection: smudge)
    }

    private static func resolveReflection(width: Int, height: Int, cases: [Coordinate2D: Case], ignoring reflection: Reflection? = nil) throws -> Reflection {
        // Try verticaly
        var potentialV = Set<Int>(1..<width)
        var carryV: [Set<Int>] = []
        for y in 0..<height {
            let row = cases.filter({ $0.key.y == y }).sorted(by: \.key.x).map(\.value)
            var reflections = Self.getPossibleReflections(in: row)
            if reflection == nil {
                potentialV.formIntersection(reflections)
                if potentialV.isEmpty {
                    break
                }
            } else {
                if case let .some(.vertical(column: column)) = reflection {
                    reflections.remove(column)
                }
                carryV.append(reflections)
            }
        }
        if potentialV.count == 1 {
            return .vertical(column: potentialV.first.unsafelyUnwrapped)
        }
        if reflection != nil {
            let potentialV = carryV
                .combinations(ofCount: carryV.count-1)
                .compactMap({
                    let intersection = $0.reduce(Set<Int>(1..<width), { $0.intersection($1) })
                    return intersection.count == 1 ? intersection.first.unsafelyUnwrapped : nil
                })
            if potentialV.count == 1 {
                return .vertical(column: potentialV.first.unsafelyUnwrapped)
            }
        }

        // Try horizontaly
        var potentialH = Set<Int>(1..<height)
        var carryH: [Set<Int>] = []
        for x in 0..<width {
            let column = cases.filter({ $0.key.x == x }).sorted(by: \.key.y).map(\.value)
            var reflections = Self.getPossibleReflections(in: column)
            if reflection == nil {
                potentialH.formIntersection(reflections)
                if potentialH.isEmpty {
                    break
                }
            } else {
                if case let .some(.horizontal(row: row)) = reflection {
                    reflections.remove(row)
                }
                carryH.append(reflections)
            }
        }
        if potentialH.count == 1 {
            return .horizontal(row: potentialH.first.unsafelyUnwrapped)
        }
        if reflection != nil {
            let potentialH = carryH
                .combinations(ofCount: carryH.count-1)
                .compactMap({
                    let intersection = $0.reduce(Set<Int>(1..<height), { $0.intersection($1) })
                    return intersection.count == 1 ? intersection.first.unsafelyUnwrapped : nil
                })
            if potentialH.count == 1 {
                return .horizontal(row: potentialH.first.unsafelyUnwrapped)
            }
        }

        throw ExecutionError.unsolvable
    }

    private static var cache: [String: Set<Int>] = [:]
    private static func getPossibleReflections(in suite: [Case]) -> Set<Int> {
        let key = String(suite.map(\.rawValue))
        if let cached = cache[key] {
            return cached
        }
        let value = computePossibleReflections(in: suite)
        cache[key] = value
        cache[String(key.reversed())] = Set(value.map({ key.count - $0 }))
        return value
    }
    private static func computePossibleReflections(in suite: [Case]) -> Set<Int> {
        var found: Set<Int> = []
        potentialLoop: for potential in 1..<suite.count {
            let a = String(suite[0..<potential].reversed().map(\.rawValue))
            let b = String(suite[potential...].map(\.rawValue))
            if a.hasPrefix(b) || b.hasPrefix(a) {
                found.insert(potential)
            }
        }
        return found
    }
}

// MARK: - PART 1

extension Day13 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 405, fromRaw: example)
        ]
    }

    // Too low: 14599
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.map(\.reflection).reduce(0) {
            switch $1 {
            case .horizontal(row: let row):
                return $0 + (100 * row)
            case .vertical(column: let column):
                return $0 + column
            }
        }
    }
}

// MARK: - PART 2

extension Day13 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 400, fromRaw: example)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.compactMap(\.smudgeReflection).reduce(0) {
            switch $1 {
            case .horizontal(row: let row):
                return $0 + (100 * row)
            case .vertical(column: let column):
                return $0 + column
            }
        }
    }
}
