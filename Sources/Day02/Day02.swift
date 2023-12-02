//
//  Day02.swift
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
struct Day02: Puzzle {
    typealias Input = [Game]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

struct Game: Parsable {
    struct Draw {
        let red: Int
        let green: Int
        let blue: Int

        static func parse(raw: String) throws -> Game.Draw {
            var colors: [String: Int] = [:]
            let components = raw.components(separatedBy: ", ")
            for component in components {
                let sub = component.components(separatedBy: " ")
                guard sub.count == 2, ["red", "green", "blue"].contains(sub[1]) else {
                    throw InputError.unexpectedInput(unrecognized: raw)
                }
                guard let amount = Int(sub[0]) else {
                    throw InputError.couldNotCast(target: Int.self)
                }
                colors[sub[1]] = amount
            }
            return Draw(red: colors["red"] ?? 0, green: colors["green"] ?? 0, blue: colors["blue"] ?? 0)
        }
    }

    let id: Int
    let red: Int
    let green: Int
    let blue: Int

    var power: Int {
        red * green * blue
    }

    func isPossible(with draw: Draw) -> Bool {
        return red <= draw.red && green <= draw.green && blue <= draw.blue
    }

    static func parse(raw: String) throws -> Game {
        let regex = #/Game ([0-9]+): (.+)/#
        guard let match = raw.matches(of: regex).first else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        guard let id = Int(match.output.1) else {
            throw InputError.couldNotCast(target: Int.self)
        }
        let draws = try match.output.2
            .components(separatedBy: "; ")
            .map({ try Draw.parse(raw: $0) })
        return Game(id: id, red: draws.map(\.red).max() ?? 0, green: draws.map(\.green).max() ?? 0, blue: draws.map(\.blue).max() ?? 0)
    }
}

// MARK: - PART 1

extension Day02 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 8, fromRaw: "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green\nGame 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue\nGame 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red\nGame 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red\nGame 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input
            .filter({ $0.isPossible(with: .init(red: 12, green: 13, blue: 14)) })
            .map(\.id)
            .reduce(0, +)
    }
}

// MARK: - PART 2

extension Day02 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 2286, fromRaw: "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green\nGame 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue\nGame 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red\nGame 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red\nGame 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input
            .map(\.power)
            .reduce(0, +)
    }
}
