//
//  Player.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Which player, white or black?
public enum Player {
    case white
    case black

    public var symbol: String {
        switch self {
        case .white: return "W"
        case .black: return "B"
        }
    }
}
