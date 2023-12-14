//
//  Day14.swift
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
struct Day14: Puzzle {
    typealias Input = Dish
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example = """
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
"""

struct Dish: Parsable, Hashable, CustomStringConvertible {
    enum Rock: Character {
        case rounded = "O"
        case cube = "#"
    }

    let width: Int
    let height: Int
    let rocks: [Coordinate2D: Rock]

    var description: String {
        var description = "\n"
        for y in 0..<height {
            for x in 0..<width {
                description.append(rocks[.init(x: x, y: y)]?.rawValue ?? ".")
            }
            description += "\n"
        }
        return description
    }

    var load: Int {
        rocks
            .filter({ $0.value == .rounded })
            .reduce(0, { $0 + height - $1.key.y })
    }

    func tilted(_ direction: Direction2D) -> Dish {
        switch direction {
        case .north, .south:
            return tiltVerticaly(direction)
        default:
            return tiltHorizontaly(direction)
        }
    }

    func cycled() -> Dish {
        tilted(.north).tilted(.west).tilted(.south).tilted(.east)
    }

    private func tiltVerticaly(_ direction: Direction2D) -> Dish {
        assert(direction == .north || direction == .south)
        var newRocks: [Coordinate2D: Rock] = [:]
        var coordinates = Array(0..<height)
        if direction == .south {
            coordinates = coordinates.reversed()
        }
        for x in 0..<width {
            yLoop: for y in coordinates {
                let current = Coordinate2D(x: x, y: y)
                switch rocks[current] {
                case .some(.cube):
                    newRocks[current] = .cube
                    fallthrough
                case .none:
                    continue yLoop
                default:
                    break
                }
                var potential = current
                repeat {
                    let next = potential.moved(to: direction)
                    if newRocks[next] != nil || next.y < 0 || next.y >= height {
                        newRocks[potential] = .rounded
                        continue yLoop
                    }
                    potential = next
                } while true
            }
        }
        return .init(width: width, height: height, rocks: newRocks)
    }

    private func tiltHorizontaly(_ direction: Direction2D) -> Dish {
        assert(direction == .west || direction == .east)
        var newRocks: [Coordinate2D: Rock] = [:]
        var coordinates = Array(0..<width)
        if direction == .east {
            coordinates = coordinates.reversed()
        }
        for y in 0..<height {
            xLoop: for x in coordinates {
                let current = Coordinate2D(x: x, y: y)
                switch rocks[current] {
                case .some(.cube):
                    newRocks[current] = .cube
                    fallthrough
                case .none:
                    continue xLoop
                default:
                    break
                }
                var potential = current
                repeat {
                    let next = potential.moved(to: direction)
                    if newRocks[next] != nil || next.x < 0 || next.x >= width {
                        newRocks[potential] = .rounded
                        continue xLoop
                    }
                    potential = next
                } while true
            }
        }
        return .init(width: width, height: height, rocks: newRocks)
    }

    static func parse(raw: String) throws -> Dish {
        let lines = raw.components(separatedBy: .newlines)
        let height = lines.count
        let width = lines[0].count
        var rocks: [Coordinate2D: Rock] = [:]
        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() where char != "." {
                rocks[.init(x: x, y: y)] = Rock(rawValue: char).unsafelyUnwrapped
            }
        }
        return .init(width: width, height: height, rocks: rocks)
    }
}

// MARK: - PART 1

extension Day14 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 136, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.tilted(.north).load
    }
}

// MARK: - PART 2

extension Day14 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 64, fromRaw: example)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let target = 1_000_000_000
        var current = input
        var seen: [Dish: Int] = [input: 0]
        var offset: Int?
        var size: Int?
        for index in 1...target {
            current = current.cycled()
            if let alreadySeen = seen[current] {
                offset = alreadySeen
                size = seen.count - alreadySeen
                break
            }
            seen[current] = index
        }
        if let offset, let size {
            let remaining = (target - offset) % size
            for _ in 0..<remaining {
                current = current.cycled()
            }
        }
        return current.load
    }
}
