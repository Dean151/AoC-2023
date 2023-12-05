//
//  Day05.swift
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
struct Day05: Puzzle {
    typealias Input = Garden
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example = """
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"""

extension Array<ClosedRange<Int>> {
    var customDescription: String {
        "[\(map({"\($0.lowerBound)...\($0.upperBound)"}).joined(separator: ", "))]"
    }
}

struct Garden: Parsable {
    let seeds: [Int]
    let maps: Maps

    func location(for seed: Int) -> Int {
        maps.destination(for: seed)
    }

    func seed(from location: Int) -> Int {
        maps.source(from: location)
    }

    static func parse(raw: String) throws -> Garden {
        let parts = raw.components(separatedBy: "\n\n")
        guard parts.count == 8 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        let seeds = parts[0].components(separatedBy: .whitespaces).compactMap(Int.init)
        if seeds.isEmpty {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        let maps = try parts[1...].map({ try Maps.parse(raw: $0) }).reduce(Maps(maps: []), {
            $0.combined(with: $1)
        })
        return Garden(
            seeds: seeds,
            maps: maps
        )
    }
}

extension Garden {
    struct Map: Parsable, CustomStringConvertible {
        let sources: ClosedRange<Int>
        let destinations: ClosedRange<Int>

        var source: Int {
            sources.lowerBound
        }
        var destination: Int {
            destinations.lowerBound
        }
        var size: Int {
            return sources.count
        }

        var description: String {
            "\(destination) \(source) \(size)"
        }

        func source(from value: Int) -> Int {
            return source + (value - destination)
        }

        func destination(for value: Int) -> Int {
            return destination + (value - source)
        }

        init(destination: Int, source: Int, length: Int) {
            self.sources = source...(source + length - 1)
            self.destinations = destination...(destination + length - 1)
        }

        static func parse(raw: String) throws -> Garden.Map {
            let values = raw.components(separatedBy: .whitespaces).compactMap(Int.init)
            guard values.count == 3 else {
                throw InputError.unexpectedInput(unrecognized: raw)
            }
            return .init(destination: values[0], source: values[1], length: values[2])
        }
    }
    struct Maps: Parsable {
        let maps: [Map]

        func combined(with other: Maps) -> Maps {
            var merged = (maps.map(\.sources) + maps.map(\.destinations) + other.maps.map(\.sources) + other.maps.map(\.destinations)).sorted(by: \.lowerBound)
            var results: [ClosedRange<Int>] = []
            while !merged.isEmpty {
                merged.sort(by: \.lowerBound)
                let current = merged.removeFirst()
                if merged.isEmpty {
                    results.append(current)
                    break
                }
                let next = merged.removeFirst()
                if current == next {
                    continue
                }
                if current.overlaps(next) {
                    let min = min(current.lowerBound, next.lowerBound)
                    let max = max(current.upperBound, next.upperBound)
                    let clamped = current.clamped(to: next)
                    if clamped.lowerBound == min {
                        let output = [clamped, clamped.upperBound+1...max]
                        merged.insert(contentsOf: output, at: 0)
                    } else if clamped.upperBound == max {
                        let output = [min...clamped.lowerBound-1, clamped]
                        merged.insert(contentsOf: output, at: 0)
                    } else {
                        let output = [min...clamped.lowerBound-1, clamped, clamped.upperBound+1...max]
                        merged.insert(contentsOf: output, at: 0)
                    }
                } else if current.lowerBound > next.lowerBound {
                    results.append(next)
                    merged.insert(current, at: 0)
                } else {
                    results.append(current)
                    merged.insert(next, at: 0)
                }
            }

            return Maps(maps: results.uniqued().map({ range in
                let destination = other.destination(for: destination(for: range.lowerBound))
                return Map(destination: destination, source: range.lowerBound, length: range.count)
            }))
        }

        func source(from value: Int) -> Int {
            maps.first(where: { $0.destinations.contains(value) })?.source(from: value) ?? value
        }

        func destination(for value: Int) -> Int {
            maps.first(where: { $0.sources.contains(value) })?.destination(for: value) ?? value
        }

        static func parse(raw: String) throws -> Garden.Maps {
            let lines = raw.components(separatedBy: .newlines)[1...]
            let maps = try lines.map({ try Map.parse(raw: $0) })
            return .init(maps: maps)
        }
    }
}

// MARK: - PART 1

extension Day05 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 35, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.seeds.map { seed in
            return input.location(for: seed)
        }.min().unsafelyUnwrapped
    }
}

// MARK: - PART 2

extension Day05 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 46, fromRaw: example) // SOMEHOW, it fails!
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let seeds: [ClosedRange<Int>] = input.seeds.chunks(ofCount: 2).map({
            let start = $0[$0.startIndex]
            let length = $0[$0.startIndex+1]
            return start...start+length-1
        })
        for location in 0...10_000_000 {
            let seed = input.seed(from: location)
            if seeds.contains(where: { $0.contains(seed) }) {
                return location
            }
        }
        throw ExecutionError.unsolvable
    }
}
