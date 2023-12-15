//
//  Day15.swift
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
struct Day15: Puzzle {
    typealias Input = [String]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static var componentsSeparator: InputSeparator {
        .string(string: ",")
    }
}

let example = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

enum Instruction: Parsable, CustomStringConvertible {
    case remove(label: String)
    case append(label: String, focal: Int)

    var description: String {
        switch self {
        case .remove(let label):
            return "\(label)-"
        case .append(let label, let focal):
            return "\(label)=\(focal)"
        }
    }

    static func parse(raw: String) throws -> Instruction {
        if raw.hasSuffix("-") {
            return .remove(label: String(raw.prefix(raw.count-1)))
        }
        let components = raw.components(separatedBy: "=")
        guard components.count == 2, let focal = Int(components[1]), (1...9).contains(focal) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .append(label: components[0], focal: focal)
    }
}

struct Lense: CustomStringConvertible {
    let label: String
    let focal: Int

    var description: String {
        "[\(label) \(focal)]"
    }
}

private extension StringProtocol {
    var hashAlgorithmValue: Int {
        if isEmpty {
            return 0
        }
        return (self.prefix(count - 1).hashAlgorithmValue + Int(last.unsafelyUnwrapped.asciiValue.unsafelyUnwrapped)) * 17 % 256
    }
}

// MARK: - PART 1

extension Day15 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 52, fromRaw: "HASH"),
            assert(expectation: 1320, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.map(\.hashAlgorithmValue).reduce(0, +)
    }
}

// MARK: - PART 2

extension Day15 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 145, fromRaw: example)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let instructions = try input.map({ try Instruction.parse(raw: $0) })
        var boxes: [Int: [Lense]] = [:]
        for instruction in instructions {
            switch instruction {
            case let .append(label: label, focal: focal):
                let hash = label.hashAlgorithmValue
                if boxes[hash] == nil {
                    boxes[hash] = []
                }
                if let index = boxes[hash]!.firstIndex(where: { $0.label == label }) {
                    boxes[hash]![index] = .init(label: label, focal: focal)
                } else {
                    boxes[hash]!.append(.init(label: label, focal: focal))
                }
            case let .remove(label: label):
                boxes[label.hashAlgorithmValue]?.removeAll(where: { $0.label == label })
            }
        }
        var totalFocalPower = 0
        boxes.forEach { box in
            box.value.enumerated().forEach { lense in
                totalFocalPower += (box.key + 1) * (lense.offset + 1) * lense.element.focal
            }
        }
        return totalFocalPower
    }
}
