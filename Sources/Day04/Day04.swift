//
//  Day04.swift
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
struct Day04: Puzzle {
    typealias Input = [Card]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example = """
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
"""

struct Card: Parsable {
    let id: Int
    let winningCount: Int

    var score: Int {
        if winningCount == 0 {
            return 0
        }
        return 1 << (winningCount - 1)
    }

    init(id: Int, winning: Set<Int>, owned: Set<Int>) {
        self.id = id
        self.winningCount = winning.intersection(owned).count
    }

    static func parse(raw: String) throws -> Card {
        let regex = #/^Card +([0-9]+): ([0-9 ]+) \| ([0-9 ]+)$/#
        guard let match = raw.wholeMatch(of: regex) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        guard let id = Int("\(match.output.1)") else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        let winning = match.output.2.components(separatedBy: .whitespaces).compactMap({ Int($0) })
        let owned = match.output.3.components(separatedBy: .whitespaces).compactMap({ Int($0) })
        return .init(id: id, winning: Set(winning), owned: Set(owned))
    }
}

// MARK: - PART 1

extension Day04 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 13, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.map(\.score).reduce(0, +)
    }
}

// MARK: - PART 2

extension Day04 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 30, fromRaw: example)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var cardsOwned: [Int] = .init(repeating: 1, count: input.count)
        for card in input where card.winningCount > 0 {
            for index in 1...card.winningCount {
                cardsOwned[card.id + index - 1] += cardsOwned[card.id - 1]
            }
        }
        return cardsOwned.reduce(0, +)
    }
}
