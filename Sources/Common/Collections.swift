//
//  File.swift
//  
//
//  Created by Thomas Durand on 05/12/2023.
//

import Foundation

extension Array {
    public func sorted(by keyPath: KeyPath<Element, some Comparable>) -> Self {
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }

    public mutating func sort(by keyPath: KeyPath<Element, some Comparable>) {
        sort { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}
