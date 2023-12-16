//
//  Day16.swift
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
struct Day16: Puzzle {
    typealias Input = Field
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example = """
.|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|....
"""

struct Field: Parsable, CustomStringConvertible {
    enum Mirror: Character {
        case northEastSouthWestMirror = "/"
        case northWestSouthEastMirror = "\\"
        case horizontalSplitter = "-"
        case verticalSplitter = "|"

        func directions(from direction: Direction2D) -> Set<Direction2D> {
            switch self {
            case .northEastSouthWestMirror:
                switch direction {
                case .north:
                    return [.east]
                case .south:
                    return [.west]
                case .west:
                    return [.south]
                case .east:
                    return [.north]
                }
            case .northWestSouthEastMirror:
                switch direction {
                case .north:
                    return [.west]
                case .south:
                    return [.east]
                case .west:
                    return [.north]
                case .east:
                    return [.south]
                }
            case .horizontalSplitter:
                switch direction {
                case .north, .south:
                    return [.west, .east]
                case .west, .east:
                    return [direction]
                }
            case .verticalSplitter:
                switch direction {
                case .west, .east:
                    return [.north, .south]
                case .north, .south:
                    return [direction]
                }
            }
        }
    }

    let width: Int
    let height: Int
    let mirrors: [Coordinate2D: Mirror]

    var description: String {
        var description = "\n"
        for y in 0..<height {
            for x in 0..<width {
                description.append(mirrors[.init(x: x, y: y)]?.rawValue ?? ".")
            }
            description += "\n"
        }
        return description
    }

    var maxEnergization: Int {
        var maxEnergization = 0
        for y in 0..<height {
            maxEnergization = max(maxEnergization, energization(with: .init(position: .init(x: 0, y: y), direction: .east)))
            maxEnergization = max(maxEnergization, energization(with: .init(position: .init(x: width-1, y: y), direction: .west)))
        }
        for x in 0..<width {
            maxEnergization = max(maxEnergization, energization(with: .init(position: .init(x: x, y: 0), direction: .south)))
            maxEnergization = max(maxEnergization, energization(with: .init(position: .init(x: x, y: height-1), direction: .north)))
        }
        return maxEnergization
    }

    func energization(with beam: Beam) -> Int {
        var resolved: Set<Beam> = []
        var energized: Set<Coordinate2D> = []
        var beams = [beam]
        while !beams.isEmpty {
            var upcoming: [Beam] = []
            resolved.formUnion(beams)
            energized.formUnion(beams.map(\.position))
            for beam in beams {
                if let mirror = mirrors[beam.position] {
                    upcoming.append(contentsOf: mirror.directions(from: beam.direction).map({ Beam(position: beam.position, direction: $0) }))
                } else {
                    // Unchanged
                    upcoming.append(beam)
                }
            }
            beams = upcoming.map(\.next).filter({ !$0.position.outOfBounds(width: width, height: height) && !resolved.contains($0) })
        }
        return energized.count
    }

    static func parse(raw: String) throws -> Field {
        let lines = raw.components(separatedBy: .newlines)
        let width = lines[0].count
        let height = lines.count
        var mirrors: [Coordinate2D: Mirror] = [:]
        for (y,line) in lines.enumerated() {
            for (x,char) in line.enumerated() {
                guard let mirror = Mirror(rawValue: char) else {
                    continue
                }
                mirrors[.init(x: x, y: y)] = mirror
            }
        }
        return .init(width: width, height: height, mirrors: mirrors)
    }
}

struct Beam: Hashable {
    let position: Coordinate2D
    let direction: Direction2D

    var next: Beam {
        return .init(position: position.moved(to: direction), direction: direction)
    }
}

// MARK: - PART 1

extension Day16 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 46, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.energization(with: Beam(position: .zero, direction: .east))
    }
}

// MARK: - PART 2

extension Day16 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 51, fromRaw: example)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.maxEnergization
    }
}
