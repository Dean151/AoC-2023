//
//  Day07.swift
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
struct Day07: Puzzle {
    typealias Input = [Hand]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

let example = """
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
"""

enum Card: Character, Equatable, Comparable {
    case ace = "A"
    case king = "K"
    case queen = "Q"
    case jack = "J"
    case ten = "T"
    case nine = "9"
    case eight = "8"
    case seven = "7"
    case six = "6"
    case five = "5"
    case four = "4"
    case three = "3"
    case two = "2"
    case joker = "1"

    var value: Int {
        switch self {
        case .ace: 14
        case .king: 13
        case .queen: 12
        case .jack: 11
        case .ten: 10
        case .nine: 9
        case .eight: 8
        case .seven: 7
        case .six: 6
        case .five: 5
        case .four: 4
        case .three: 3
        case .two: 2
        case .joker: 1
        }
    }

    static func < (lhs: Card, rhs: Card) -> Bool {
        lhs.value < rhs.value
    }
}

enum HandType: CustomStringConvertible {
    case five(of: Card)
    case four(of: Card, and: Card)
    case full(of: Card, and: Card)
    case three(of: Card, and: (Card, Card))
    case twoPairs(of: (Card, Card), and: Card)
    case pair(of: Card, and: (Card, Card, Card))
    case none(of: (Card, Card, Card, Card, Card))

    var value: Int {
        switch self {
        case .five: 6
        case .four: 5
        case .full: 4
        case .three: 3
        case .twoPairs: 2
        case .pair: 1
        case .none: 0
        }
    }

    var subValues: [Card] {
        switch self {
        case let .five(type):
            [type]
        case let .four(type, and: other):
            [type, other]
        case let .full(triple, double):
            [triple, double]
        case let .three(triple, (higher, lower)):
            [triple, higher, lower]
        case let .twoPairs((higherDouble, lowerDouble), other):
            [higherDouble, lowerDouble, other]
        case let .pair(double, (higher, middle, lower)):
            [double, higher, middle, lower]
        case let .none(cards):
            [cards.0, cards.1, cards.2, cards.3, cards.4]
        }
    }

    var description: String {
        String(subValues.map(\.rawValue))
    }

    static func resolve(cards: [Card]) throws -> HandType {
        guard cards.count == 5 else {
            throw InputError.unexpectedInput()
        }
        var cardsByCount = [Card: Int](zip(cards, [Int](repeating: 1, count: cards.count)), uniquingKeysWith: { $0 + $1 })
        // Resolve joker
        let jokerCount = cardsByCount[.joker] ?? 0
        cardsByCount.removeValue(forKey: .joker)
        var sortedCardsByCount = cardsByCount.sorted(by: {
            if $0.1 == $1.1 {
                return $0.0 > $1.0
            }
            return $0.1 > $1.1
        })
        if sortedCardsByCount.isEmpty {
            sortedCardsByCount.append((.joker, jokerCount))
        } else {
            sortedCardsByCount[0].value += jokerCount
        }

        switch sortedCardsByCount.count {
        case 1:
            return .five(of: sortedCardsByCount[0].0)
        case 2:
            switch sortedCardsByCount[0].1 {
            case 4:
                return .four(of: sortedCardsByCount[0].0, and: sortedCardsByCount[1].0)
            case 3:
                return .full(of: sortedCardsByCount[0].0, and: sortedCardsByCount[1].0)
            default:
                throw InputError.unexpectedInput()
            }
        case 3:
            switch sortedCardsByCount[0].1 {
            case 3:
                return .three(of: sortedCardsByCount[0].0, and: (sortedCardsByCount[1].0, sortedCardsByCount[2].0))
            case 2:
                return .twoPairs(of: (sortedCardsByCount[0].0, sortedCardsByCount[1].0), and: sortedCardsByCount[2].0)
            default:
                throw InputError.unexpectedInput()
            }
        case 4:
            return .pair(of: sortedCardsByCount[0].0, and: (sortedCardsByCount[1].0, sortedCardsByCount[2].0, sortedCardsByCount[3].0))
        case 5:
            return .none(of: (sortedCardsByCount[0].0, sortedCardsByCount[1].0, sortedCardsByCount[2].0, sortedCardsByCount[3].0, sortedCardsByCount[4].0))
        default:
            throw InputError.unexpectedInput()
        }
    }
}

struct Hand: Parsable {
    let raw: [Card]
    let bid: Int

    func resolve() throws -> ResolvedHand {
        .init(hand: self, type: try .resolve(cards: raw))
    }

    func jackToJoker() throws -> Hand {
        .init(raw: raw.map({ $0 == .jack ? .joker : $0 }), bid: bid)
    }

    static func parse(raw: String) throws -> Hand {
        let components = raw.components(separatedBy: .whitespaces)
        guard components.count == 2, let bid = Int(components[1]) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        let cards = components[0].compactMap({ Card(rawValue: $0) })
        guard cards.count == 5 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .init(raw: cards, bid: bid)
    }
}

struct ResolvedHand: Equatable, Comparable {
    let hand: Hand
    let type: HandType

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.type.value == rhs.type.value && lhs.hand.raw == rhs.hand.raw
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.type.value == rhs.type.value {
            for (lhs, rhs) in zip(lhs.hand.raw, rhs.hand.raw) {
                if lhs == rhs {
                    continue
                }
                return lhs < rhs
            }
        }
        return lhs.type.value < rhs.type.value
    }
}

// MARK: - PART 1

extension Day07 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 6440, fromRaw: example)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        return try input
            .map({ try $0.resolve() })
            .sorted()
            .enumerated()
            .map({ index, hand in
                (index + 1) * hand.hand.bid
            })
            .reduce(0, +)
    }
}

// MARK: - PART 2

extension Day07 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 5905, fromRaw: example)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        return try input
            .map({ try $0.jackToJoker().resolve() })
            .sorted()
            .enumerated()
            .map({ index, hand in
                (index + 1) * hand.hand.bid
            })
            .reduce(0, +)
    }
}
