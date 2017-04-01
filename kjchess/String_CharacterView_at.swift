//
//  String_CharacterView_at.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

extension String.CharacterView {
    /// Get the character at the specified numeric offset.
    ///
    /// - parameter offset: Numeric offset from start index.
    ///
    /// - returns: `Character`
    func at(offset: Int) -> Character {
        return self[index(startIndex, offsetBy: offset)]
    }
}
