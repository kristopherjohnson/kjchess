//
//  Array_shuffle.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

extension Array {
    /// Shuffle the elements of the array randomly.
    public mutating func shuffle() {
        for i in 0..<(count - 1) {
            let remainingCount = UInt32(count - i)
            let swapIndex = i + Int(arc4random_uniform(remainingCount))
            if swapIndex != i {
                let temp = self[i]
                self[i] = self[swapIndex]
                self[swapIndex] = temp
            }
        }
    }
}
