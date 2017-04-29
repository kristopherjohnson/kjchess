//
//  Position_after_coordinateMove.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

extension Position {
    /// Return position after applying specified move in coordinate notation.
    ///
    /// - parameter coordinateMove: A string like "e2e4" or "e7e8q"
    ///
    /// - returns: Resulting `Position`.
    ///
    /// - throws: `ChessError` if the move string doesn't have valid syntax or does not identify a legal move from this position.
    public func after(coordinateMove: String) throws -> Position {
        let move = try find(coordinateMove: coordinateMove)
        return after(move)
    }

    /// Return position after applying specified moves in coordinate notation.
    ///
    /// - parameter coordinateMoves: A sequence of strings like "e2e4" or "e7e8q"
    ///
    /// - returns: Resulting `Position`.
    ///
    /// - throws: `ChessError` if any of the move strings doesn't have valid syntax or does not identify a legal move.
    public func after(coordinateMoves: String...) throws -> Position {
        var result = self
        for move in coordinateMoves {
            result = try result.after(coordinateMove: move)
        }
        return result
    }

    /// Get the full `Move` for the given coordinate move string.
    ///
    /// - parameter coordinateMove: A string like "e2e4" or "e7e8q"
    ///
    /// - returns: The `Move`.
    ///
    /// - throws: `ChessError` if the move string doesn't have valid syntax or does not identify a legal move from this position.
    public func find(coordinateMove: String) throws -> Move {
        guard let (from, to, promotedKind) = parseCoordinateMove(coordinateMove) else {
            throw ChessError.invalidCoordinateMove(move: coordinateMove)
        }

        // TODO: Add an overload legalMoves(from: Location)
        // that only considers moves by the piece at that location.
        let moves = legalMoves().filter {
            $0.from == from && $0.to == to
        }

        if moves.count == 1 {
            return moves[0]
        }

        if let promotedKind = promotedKind {
            let moves = moves.filter {
                $0.promotedKind == promotedKind
            }

            if moves.count == 1 {
                return moves[0]
            }
        }

        throw ChessError.noMatchingCoordinateMoves(from: from, to: to, promotedKind: promotedKind)
    }
}
