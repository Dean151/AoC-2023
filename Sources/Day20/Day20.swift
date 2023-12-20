//
//  Day20.swift
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
struct Day20: Puzzle {
    typealias Input = Configuration
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example1 = """
broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a
"""
let example2 = """
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
"""

struct Configuration: Parsable {
    let broadcaster: [String]
    let modules: [String: Module]
    let inputs: [String: Set<String>]

    func press(low: inout Int, high: inout Int, onFlipFlops: inout Set<String>, conjonctionsMemory: inout [String: Set<String>], conjonctionSendsLow: (String) -> Void = { _ in }) throws {
        // A press is a low signal on the button
        low += 1
        // false: low, true: high
        var toProcess = Self.generatePulses(from: "broadcaster", destinations: broadcaster, isHigh: false)
        while !toProcess.isEmpty {
            let pulse = toProcess.removeFirst()
            if pulse.isHigh {
                high += 1
            } else {
                low += 1
            }
            let name = pulse.destination
            guard let module = modules[name] else {
                continue
            }
            switch module.kind {
            case .flipflop:
                if !pulse.isHigh {
                    if onFlipFlops.contains(name) {
                        // turning off
                        onFlipFlops.remove(name)
                        toProcess += Self.generatePulses(from: name, destinations: module.destinations, isHigh: false)
                    } else {
                        // turning on
                        onFlipFlops.insert(name)
                        toProcess += Self.generatePulses(from: name, destinations: module.destinations, isHigh: true)
                    }
                }
            case .conjonction:
                if conjonctionsMemory[name] == nil {
                    conjonctionsMemory[name] = []
                }
                // Update memory
                if pulse.isHigh {
                    conjonctionsMemory[name]!.insert(pulse.from)
                } else {
                    conjonctionsMemory[name]!.remove(pulse.from)
                }
                let allHigh = conjonctionsMemory[name]!.count == inputs[name]!.count
                if allHigh {
                    conjonctionSendsLow(name)
                }
                toProcess += Self.generatePulses(from: name, destinations: module.destinations, isHigh: !allHigh)
            }
        }
    }

    func pulsesSent(afterPressing count: Int) throws -> (low: Int, high: Int) {
        var onFlipFlops: Set<String> = []
        var conjonctionsMemory: [String: Set<String>] = [:]
        var (low, high) = (0,0)
        var press = 0
        while press < count {
            press += 1
            try self.press(low: &low, high: &high, onFlipFlops: &onFlipFlops, conjonctionsMemory: &conjonctionsMemory)
            if onFlipFlops.isEmpty && (conjonctionsMemory.isEmpty || conjonctionsMemory.allSatisfy({ $0.value.isEmpty })) {
                // Cycle found!
                let cycles = count / press
                let remaining = count % press
                low *= cycles
                high *= cycles
                press = count - remaining
            }
        }
        return (low, high)
    }

    func buttonPressesBeforeLowPulse(to name: String) throws -> Int {
        // Find the initial conjonctions
        let conjonctions = broadcaster.flatMap({ modules[$0]!.destinations }).filter({ modules[$0]!.kind == .conjonction  })

        // Find when they all send their first low pulse
        var onFlipFlops: Set<String> = []
        var conjonctionsMemory: [String: Set<String>] = [:]
        var (low, high) = (0,0)
        var lowPulses: [String:Int] = [:]
        var count = 0
        while lowPulses.count < 4 {
            count += 1
            try self.press(low: &low, high: &high, onFlipFlops: &onFlipFlops, conjonctionsMemory: &conjonctionsMemory) { conjonction in
                if lowPulses[conjonction] == nil && conjonctions.contains(conjonction) {
                    lowPulses[conjonction] = count
                }
            }
        }
        return leastCommonMultiple(Array(lowPulses.values))
    }

    static func generatePulses(from: String, destinations: [String], isHigh: Bool) -> [Pulse] {
        destinations.map({ Pulse(from: from, destination: $0, isHigh: isHigh) })
    }

    static func parse(raw: String) throws -> Configuration {
        var lines = raw.components(separatedBy: .newlines)
        let broadcastIndex = lines.firstIndex(where: { $0.hasPrefix("broadcaster -> ") }).unsafelyUnwrapped
        let broadcaster = lines[broadcastIndex].components(separatedBy: " -> ")[1].components(separatedBy: ", ")
        lines.remove(at: broadcastIndex)
        let modules = try lines.map({ try Module.parse(raw: $0) })
        var inputs: [String: Set<String>] = [:]
        for destination in broadcaster {
            if inputs[destination] != nil {
                inputs[destination]!.insert("broadcaster")
            } else {
                inputs[destination] = ["broadcaster"]
            }
        }
        for module in modules {
            for destination in module.destinations {
                if inputs[destination] != nil {
                    inputs[destination]!.insert(module.name)
                } else {
                    inputs[destination] = [module.name]
                }
            }
        }
        let namedModules = [String: Module](zip(modules.map(\.name), modules), uniquingKeysWith: { a, _ in a })
        return Configuration(broadcaster: broadcaster, modules: namedModules, inputs: inputs)
    }
}

struct Module: Parsable {
    enum Kind: Character {
        case flipflop = "%"
        case conjonction = "&"
    }

    let name: String
    let kind: Kind
    let destinations: [String]

    static func parse(raw: String) throws -> Module {
        let regex = #/(%|&)([a-z]+) -> ([a-z, ]+)/#
        guard let matches = raw.wholeMatch(of: regex) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        guard let kind = matches.output.1.first.flatMap(Kind.init) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        let name = String(matches.output.2)
        let destinations = matches.output.3.components(separatedBy: ", ")
        return .init(name: name, kind: kind, destinations: destinations)
    }
}

struct Pulse {
    let from: String
    let destination: String
    let isHigh: Bool
}

// MARK: - PART 1

extension Day20 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 32000000, fromRaw: example1),
            assert(expectation: 11687500, fromRaw: example2)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let (low, high) = try input.pulsesSent(afterPressing: 1000)
        return low * high
    }
}

// MARK: - PART 2

extension Day20 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        try input.buttonPressesBeforeLowPulse(to: "rx")
    }
}
