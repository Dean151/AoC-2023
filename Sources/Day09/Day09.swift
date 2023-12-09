//
//  Day09.swift
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
struct Day09: Puzzle {
    typealias Input = [[Int]]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static func transform(raw: String) async throws -> [[Int]] {
        raw.components(separatedBy: .newlines).map({ $0.components(separatedBy: .whitespaces).compactMap(Int.init) })
    }
}

// MARK: - PART 1

let example = """
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"""

private extension Array<Int> {
    var intervals: [Int] {
        adjacentPairs().map({ $0.1 - $0.0 })
    }

    var nextValue: Int {
        var carry = [last.unsafelyUnwrapped]
        var current = intervals
        while !current.allSatisfy({ $0 == 0 }) {
            carry.append(current.last.unsafelyUnwrapped)
            current = current.intervals
        }
        var value = 0
        while let last = carry.popLast() {
            value += last
        }
        return value
    }

    var previousValue: Int {
        var carry = [first.unsafelyUnwrapped]
        var current = intervals
        while !current.allSatisfy({ $0 == 0 }) {
            carry.append(current.first.unsafelyUnwrapped)
            current = current.intervals
        }
        var value = 0
        while let last = carry.popLast() {
            value = last - value
        }
        return value
    }
}

extension Day09 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 114, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.map({ $0.nextValue }).reduce(0, +)
    }
}

// MARK: - PART 2

extension Day09 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 2, fromRaw: example)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.map({ $0.previousValue }).reduce(0, +)
    }
}
