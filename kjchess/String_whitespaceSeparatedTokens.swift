//
//  String_whitespaceSeparatedTokens.swift
//  kjchess
//
//  Created by Kristopher Johnson on 4/9/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

extension String {
    /// Split a `String` into whitespace-separated tokens.
    ///
    /// Arbitrary whitespace between tokens is allowed.
    /// All whitespace will be removed.
    public func whitespaceSeparatedTokens() -> [String] {
        return components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    }
}
