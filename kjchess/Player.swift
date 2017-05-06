//
//  Player.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

/// Which player, white or black?
public enum Player {
    case empty
    case white
    case black

    public var symbol: String {
        switch self {
        case .white: return "W"
        case .black: return "B"
        case .empty:
            assert(false)
            return " "
        }
    }

    public var opponent: Player {
        switch self {
        case .white: return .black
        case .black: return .white
        case .empty:
            assert(false)
            return .empty
        }
    }
}

// MARK:= CustomStringConvertible

extension Player: CustomStringConvertible {
    public var description: String {
        switch self {
        case .white: return "white"
        case .black: return "black"
        case .empty: return "(empty)"
        }
    }
}
