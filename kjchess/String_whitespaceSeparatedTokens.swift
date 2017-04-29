//
//  String_whitespaceSeparatedTokens.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

extension String {
    /// Split a `String` into whitespace-separated tokens.
    ///
    /// Arbitrary whitespace between tokens is allowed.
    /// All whitespace will be removed.
    public func whitespaceSeparatedTokens() -> [String] {
        return components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    }
}
