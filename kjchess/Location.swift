//
//  LocationSymbols.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Specifies a location on the chessboard.
///
/// `file` is the "X-coordinate", and `rank` is the
/// "Y-coordinate".  The zeroth rank is on the white
/// side.
///
/// File and rank indexes are in the range 0...7.
///
/// So, for example, the white queen's initial location
/// (d1) is at `Location(3, 0)`, and the black king's
/// initial location (e8) is at `Location(4, 7)`.
public struct Location {
    let file: Int
    let rank: Int

    /// Initializer
    ///
    /// - parameter file: an integer in the range `0...7`.
    /// - parameter rank: an integer in the range `0...7`.
    public init(_ file: Int, _ rank: Int) {
        assert(Board.isValid(file: file, rank: rank), "file and rank must be valid")
        self.file = file
        self.rank = rank
    }

    /// Initializer
    ///
    /// - parameter fileCharacter: a character in the range "a"..."h".
    /// - parameter rankCharacter: a character in the range "1"..."8"
    ///
    /// - returns: `nil` if parameters are not valid.
    public init?(_ fileCharacter: Character, _ rankCharacter: Character) {
        if let file = Location.fileIndex(character: fileCharacter),
            let rank = Location.rankIndex(character: rankCharacter)
        {
            self.file = file
            self.rank = rank
        }
        else {
            return nil
        }
    }

    /// Initializer
    ///
    /// - parameter algebraicNotationString: A two-character string like "e1" or "h8".
    ///
    /// - returns: `nil` if the parameter is not a valid algebraic-notation string.
    public init?(_ algebraicNotationString: String) {
        let chars = algebraicNotationString.characters
        if chars.count != 2 { return nil }
        if let file = Location.fileIndex(character: chars.at(offset: 0)),
            let rank = Location.rankIndex(character: chars.at(offset: 1))
        {
            self.file = file
            self.rank = rank
        }
        else {
            return nil
        }
    }

    /// Create a new `Location` if the given file and rank are valid.
    static func ifValid(file: Int, rank: Int) -> Location? {
        if !Board.isValid(file: file, rank: rank) {
            return nil
        }
        return Location(file, rank)
    }

    /// Return location in algebraic notation.
    public var symbol: String {
        return "\(fileSymbol)\(rankSymbol)"
    }

    public var fileSymbol: String {
        switch file {
        case 0: return "a"
        case 1: return "b"
        case 2: return "c"
        case 3: return "d"
        case 4: return "e"
        case 5: return "f"
        case 6: return "g"
        case 7: return "h"
        default:
            assert(false, "file must be in the range 0...7")
            return "?"
        }
    }

    public var rankSymbol: String {
        if (0...7).contains(rank) {
            return "\(rank + 1)"
        }
        else {
            assert(false, "rank must be in the range 0...7")
            return "?"
        }
    }

    /// Given a character "a"..."h", return the file index.
    ///
    /// - returns: Index in the range 0...7, or `nil` if character is not a valid file.
    public static func fileIndex(character: Character) -> Int? {
        switch character {
        case "a", "A": return 0
        case "b", "B": return 1
        case "c", "C": return 2
        case "d", "D": return 3
        case "e", "E": return 4
        case "f", "F": return 5
        case "g", "G": return 6
        case "h", "H": return 7
        default:       return nil
        }
    }

    /// Given a character "1"..."8", return the rank index.
    ///
    /// - returns: Index in the range 0...7, or `nil` if character is not a valid rank.
    public static func rankIndex(character: Character) -> Int? {
        switch character {
        case "1": return 0
        case "2": return 1
        case "3": return 2
        case "4": return 3
        case "5": return 4
        case "6": return 5
        case "7": return 6
        case "8": return 7
        default:  return nil
        }
    }

    public func isSameDiagonal(_ other: Location) -> Bool {
        let dFile = abs(file - other.file)
        let dRank = abs(rank - other.rank)
        return dFile == dRank
    }

    public func isSameFile(_ other: Location) -> Bool {
        return file == other.file
    }

    public func isSameRank(_ other: Location) -> Bool {
        return rank == other.rank
    }
}

// MARK: - Equatable

extension Location: Equatable {}

public func == (_ lhs: Location, _ rhs: Location) -> Bool {
    return lhs.file == rhs.file
        && lhs.rank == rhs.rank
}

// MARK:- Hashable

extension Location: Hashable {
    public var hashValue: Int {
        return (file << 3) | rank
    }
}

// MARK:- CustomStringConvertible

extension Location: CustomStringConvertible {
    public var description: String {
        if (0...7).contains(rank) && (0...7).contains(file) {
            return symbol
        }
        return "Location(file: \(file), rank:\(rank)"
    }
}

// MARK:- CustomDebugStringConvertible

extension Location: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK:- Algebraic-notation symbols

public let a1 = Location(0, 0)
public let a2 = Location(0, 1)
public let a3 = Location(0, 2)
public let a4 = Location(0, 3)
public let a5 = Location(0, 4)
public let a6 = Location(0, 5)
public let a7 = Location(0, 6)
public let a8 = Location(0, 7)

public let b1 = Location(1, 0)
public let b2 = Location(1, 1)
public let b3 = Location(1, 2)
public let b4 = Location(1, 3)
public let b5 = Location(1, 4)
public let b6 = Location(1, 5)
public let b7 = Location(1, 6)
public let b8 = Location(1, 7)

public let c1 = Location(2, 0)
public let c2 = Location(2, 1)
public let c3 = Location(2, 2)
public let c4 = Location(2, 3)
public let c5 = Location(2, 4)
public let c6 = Location(2, 5)
public let c7 = Location(2, 6)
public let c8 = Location(2, 7)

public let d1 = Location(3, 0)
public let d2 = Location(3, 1)
public let d3 = Location(3, 2)
public let d4 = Location(3, 3)
public let d5 = Location(3, 4)
public let d6 = Location(3, 5)
public let d7 = Location(3, 6)
public let d8 = Location(3, 7)

public let e1 = Location(4, 0)
public let e2 = Location(4, 1)
public let e3 = Location(4, 2)
public let e4 = Location(4, 3)
public let e5 = Location(4, 4)
public let e6 = Location(4, 5)
public let e7 = Location(4, 6)
public let e8 = Location(4, 7)

public let f1 = Location(5, 0)
public let f2 = Location(5, 1)
public let f3 = Location(5, 2)
public let f4 = Location(5, 3)
public let f5 = Location(5, 4)
public let f6 = Location(5, 5)
public let f7 = Location(5, 6)
public let f8 = Location(5, 7)

public let g1 = Location(6, 0)
public let g2 = Location(6, 1)
public let g3 = Location(6, 2)
public let g4 = Location(6, 3)
public let g5 = Location(6, 4)
public let g6 = Location(6, 5)
public let g7 = Location(6, 6)
public let g8 = Location(6, 7)

public let h1 = Location(7, 0)
public let h2 = Location(7, 1)
public let h3 = Location(7, 2)
public let h4 = Location(7, 3)
public let h5 = Location(7, 4)
public let h6 = Location(7, 5)
public let h7 = Location(7, 6)
public let h8 = Location(7, 7)
