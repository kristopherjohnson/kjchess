//
//  Array_randomPick.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Darwin

extension Array {
    /// Pseudorandomly select an element of the array.
    ///
    /// - returns: An `Element`, or `nil` if the array is empty.
    func randomPick() -> Element? {
        if count > 0 {
            let index = arc4random_uniform(UInt32(count))
            return self[Int(index)]
        }
        else {
            return nil
        }
    }
}
