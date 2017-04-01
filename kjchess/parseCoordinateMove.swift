//
//  parseCoordinateMove.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation
import os.log

/// Given a string like "e2e4" or "e7e8q", return the `from` and `to` locations, and optional promotion type.
///
/// - returns: (from, to, promoted?), or `nil` if not a valid coordinate move string.
public func parseCoordinateMove(_ moveString: String)
    -> (from: Location, to: Location, promoted: PieceKind?)?
{
    let chars = moveString.characters
    let len = chars.count
    if !(len == 4 || len == 5) {
        return nil
    }

    if let fromLocation = Location(chars.at(offset: 0), chars.at(offset: 1)) {
        if let toLocation = Location(chars.at(offset: 2), chars.at(offset: 3)) {
            if len == 5 {
                if let promoted = PieceKind.fromCharacter(chars.at(offset: 4)) {
                    return (fromLocation, toLocation, promoted)
                }
            }
            else {
                return (fromLocation, toLocation, nil)
            }
        }
    }

    return nil
}
