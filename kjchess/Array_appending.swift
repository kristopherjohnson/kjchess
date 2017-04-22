//
//  Array_appending.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

extension Array { // MARK:- appending/prepending

    /// Create a copy of this array with the specified element appended.
    ///
    /// - parameter newElement: Element to be appended.
    ///
    /// - returns: New `Array`.
    func appending(_ newElement: Element) -> Array {
        var a = Array(self)
        a.append(newElement)
        return a
    }

    /// Create a copy of this array with the specified element inserted before the first element.
    ///
    /// - parameter newElement: Element to be inserted at the head of the array.
    ///
    /// - returns: Hew `Array`.
    func prepending(_ newElement: Element) -> Array {
        var a = [newElement]
        a.append(contentsOf: self)
        return a
    }
}
