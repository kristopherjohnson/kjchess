//
//  Array_appendRepeating.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

extension Array {
    /// Append multiple copies of an element.
    ///
    /// - parameter repeatingElement: Element to be appended.
    /// - parameter count: Number of times to append the element.
    public mutating func appendRepeating(element: Element, count: Int) {
        for _ in 0..<count {
            append(element)
        }
    }
}
