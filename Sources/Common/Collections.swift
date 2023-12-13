
import Foundation

extension Collection {
    public subscript(safe key: Index) -> Element? {
        indices.contains(key) ? self[key] : nil
    }
}

extension Array {
    public func sorted(by keyPath: KeyPath<Element, some Comparable>) -> Self {
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }

    public mutating func sort(by keyPath: KeyPath<Element, some Comparable>) {
        sort { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}
