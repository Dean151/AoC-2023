//
//  Day12.swift
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
struct Day12: Puzzle {
    typealias Input = [SpringsRow]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example = """
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
"""

struct SpringsRow: Parsable, CustomStringConvertible {
    enum State: Character {
        case unknown = "?"
        case operational = "."
        case broken = "#"
    }

    let springs: [State]
    let groups: [Int]

    var description: String {
        "\"" + String(springs.map(\.rawValue)) + " " + groups.map(\.description).joined(separator: ",") + "\""
    }

    var possibleCombinasons: Int {
        Self.getPossibleCombinasons(springs: springs, groups: groups)
    }

    var expanded: SpringsRow {
        .init(
            springs: springs + [.unknown] + springs + [.unknown] + springs + [.unknown] + springs + [.unknown] + springs,
            groups: groups + groups + groups + groups + groups
        )
    }

    static func parse(raw: String) throws -> SpringsRow {
        let components = raw.components(separatedBy: .whitespaces)
        let springs = components[0].compactMap(State.init)
        let groups = components[1].components(separatedBy: ",").compactMap(Int.init)
        return SpringsRow(springs: springs, groups: groups)
    }

    private static var cache: [String: Int] = [:]
    private static func getPossibleCombinasons(springs: [State], groups: [Int]) -> Int {
        let key = SpringsRow(springs: springs, groups: groups).description
        if let cached = cache[key] {
            return cached
        }
        let value = computePossibleCombinasons(springs: springs, groups: groups)
        cache[key] = value
        return value
    }

    private static func computePossibleCombinasons(springs: [State], groups: [Int]) -> Int {
        guard let first = springs.first else {
            return groups.isEmpty ? 1 : 0
        }
        switch first {
        case .broken:
            guard let group = groups.first, springs.count >= group else {
                return 0
            }
            if springs[0..<group].contains(.operational) {
                return 0
            }
            if springs[group...].first == .broken {
                return 0
            }
            if springs.count > groups[0] && springs[groups[0]] == .unknown {
                return getPossibleCombinasons(springs: Array(springs[(groups[0]+1)...].trimmingPrefix(while: { $0 == .operational })), groups: Array(groups[1...]))
            }
            return getPossibleCombinasons(springs: Array(springs[groups[0]...].trimmingPrefix(while: { $0 == .operational })), groups: Array(groups[1...]))
        case .operational:
            return getPossibleCombinasons(springs: Array(springs.trimmingPrefix(while: { $0 == .operational })), groups: groups)
        case .unknown:
            return getPossibleCombinasons(springs: [.broken] + springs[1...], groups: groups)
                + getPossibleCombinasons(springs: [.operational] + springs[1...], groups: groups)
        }
    }
}

// MARK: - PART 1

extension Day12 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 21, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.reduce(0, { $0 + $1.possibleCombinasons })
    }
}

// MARK: - PART 2

extension Day12 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 525152, fromRaw: example)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.map(\.expanded).reduce(0, { $0 + $1.possibleCombinasons })
    }
}
