//
//  Day01.swift
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
struct Day01: Puzzle {
    typealias Input = [String]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day01 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 142, fromRaw: "1abc2\npqr3stu8vwx\na1b2c3d4e5f\ntreb7uchet")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input
            .map({ $0.filter({ $0.isNumber }) })
            .compactMap({ Int("\($0.first.unsafelyUnwrapped)\($0.last.unsafelyUnwrapped)") })
            .reduce(0, +)
    }
}

// MARK: - PART 2

extension Day01 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 281, fromRaw: "two1nine\neightwothree\nabcone2threexyz\nxtwone3four\n4nineeightseven2\nzoneight234\n7pqrstsixteen")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let fixed = input.map {
            $0.replacingOccurrences(of: "one", with: "one1one")
                .replacingOccurrences(of: "two", with: "two2two")
                .replacingOccurrences(of: "three", with: "three3three")
                .replacingOccurrences(of: "four", with: "four4four")
                .replacingOccurrences(of: "five", with: "five5five")
                .replacingOccurrences(of: "six", with: "six6six")
                .replacingOccurrences(of: "seven", with: "seven7seven")
                .replacingOccurrences(of: "eight", with: "eight8eight")
                .replacingOccurrences(of: "nine", with: "nine9nine")
        }
        return try await solvePartOne(fixed)
    }
}
