//
//  Day06.swift
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
struct Day06: Puzzle {
    typealias Input = [Race]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example = """
Time:      7  15   30
Distance:  9  40  200
"""

public struct Race {
    let time: Int
    let distance: Int

    var minPressWin: Int {
        (1..<time).first(where: wins).unsafelyUnwrapped
    }

    var maxPressWin: Int {
        (1..<time).reversed().first(where: wins).unsafelyUnwrapped
    }

    func wins(for press: Int) -> Bool {
        press * (time - press) > distance
    }
}

extension Array<Race>: Parsable {
    public static func parse(raw: String) throws -> Array<Race> {
        let lines = raw.components(separatedBy: .newlines)
        guard lines.count == 2 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        let times = lines[0].components(separatedBy: .whitespaces).compactMap(Int.init)
        let distances = lines[1].components(separatedBy: .whitespaces).compactMap(Int.init)
        guard times.count == distances.count else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }

        var races: [Race] = []
        for (time, distance) in zip(times, distances) {
            races.append(.init(time: time, distance: distance))
        }
        return races
    }

    var combined: Race {
        func combine(_ array: [Int]) -> Int {
            Int(array.map(String.init).joined()).unsafelyUnwrapped
        }
        return .init(time: combine(map(\.time)), distance: combine(map(\.distance)))
    }
}

// MARK: - PART 1

extension Day06 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 288, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.map { race in
            race.maxPressWin - race.minPressWin + 1
        }.reduce(1, *)
    }
}

// MARK: - PART 2

extension Day06 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 71503, fromRaw: example)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let race = input.combined
        return race.maxPressWin - race.minPressWin + 1
    }
}
