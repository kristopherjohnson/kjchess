//
//  CastlingOptions.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

/// Flags indicating which castling moves are still valid for a `Position`.
public struct CastlingOptions: OptionSet {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// `true` if white's king and kingside rook have not moved.
    public static let whiteCanCastleKingside = CastlingOptions(rawValue: 1 << 0)

    /// `true` if white's king and queenside rook have not moved.
    public static let whiteCanCastleQueenside = CastlingOptions(rawValue: 1 << 1)

    /// `true` if black's king and kingside rook have not moved.
    public static let blackCanCastleKingside = CastlingOptions(rawValue: 1 << 2)

    /// `true` if black's king and queenside rook have not moved.
    public static let blackCanCastleQueenside = CastlingOptions(rawValue: 1 << 3)

    /// Set containing all options.
    public static let all: CastlingOptions = [whiteCanCastleKingside,
                                              whiteCanCastleQueenside,
                                              blackCanCastleKingside,
                                              blackCanCastleQueenside]

    /// Empty set.
    public static let none: CastlingOptions = []
}

