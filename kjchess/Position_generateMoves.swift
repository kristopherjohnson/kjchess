//
//  Position_generateMoves.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

extension Position {
    /// Generate array of legal moves for this `Position`.
    ///
    /// The generated moves will all be valid in the sense that
    /// the piece can perform the move/capture. However, this
    /// method does not verify that the move will not leave
    /// the player's king in check or that it doesn't result
    /// in a repeated board position.
    public func generateMoves() -> AnySequence<Move> {
        let pieces = board.pieces(player: toMove)
        return AnySequence(pieces.lazy.flatMap({ (piece, location) in
            return self.generateMoves(piece: piece, location: location)
        }))
    }

    /// Generate array of legal moves for a `Piece` at the given `Location`.
    public func generateMoves(piece: Piece, location: Location) -> AnySequence<Move> {
        switch piece.kind {
        case .pawn: return generatePawnMoves(player: piece.player, location: location)
        case .knight: return generateKnightMoves(player: piece.player, location: location)
        default:
            // TODO
            return AnySequence([])
        }
    }

    // MARK:- Pawn

    static let whitePawnCaptureMoves = [(-1,  1), (1,  1)]
    static let blackPawnCaptureMoves = [(-1, -1), (1, -1)]

    static func pawnCaptureMoves(player: Player) -> [(Int, Int)] {
        switch player {
        case .white: return whitePawnCaptureMoves
        case .black: return blackPawnCaptureMoves
        }
    }

    static func pawnMoveDirection(player: Player) -> Int {
        switch player {
        case .white: return 1
        case .black: return -1
        }
    }

    static func pawnPromotionRank(player: Player) -> Int {
        switch player {
        case .white: return Board.maxRank
        case .black: return Board.minRank
        }
    }

    static func pawnStartRank(player: Player) -> Int {
        switch player {
        case .white: return Board.minRank + 1
        case .black: return Board.maxRank - 1
        }
    }

    func generatePawnMoves(player: Player, location: Location) -> AnySequence<Move> {
        let piece = Piece(player, .pawn)
        let file = location.file
        let rank = location.rank

        var result = [Move]()

        if Board.minRank < rank && rank < Board.maxRank {
            let moveDirection = Position.pawnMoveDirection(player: player)
            let nextRank = rank + moveDirection
            if board.isEmpty(file: file, rank: nextRank) {
                let to = Location(file, nextRank)

                let promotionRank = Position.pawnPromotionRank(player: player)
                if to.rank == promotionRank {
                    for kind in PieceKind.promotionKinds {
                        result.append(.promote(player: player,
                                               from: location,
                                               to: to,
                                               promotedPiece: Piece(player, kind)))
                    }
                }
                else {
                    result.append(.move(piece: piece, from: location, to: to))

                    let startRank = Position.pawnStartRank(player: player)
                    if rank == startRank {
                        let jumpRank = startRank + 2 * moveDirection
                        if board.isEmpty(file: file, rank: jumpRank) {
                            result.append(.move(piece: piece, from: location, to: Location(file, jumpRank)))
                        }
                    }
                }
            }

            let opponent = player.opponent
            let captureMoves = Position.pawnCaptureMoves(player: player)
            for (h, v) in captureMoves {
                if let captureLocation = Location.ifValid(file: file + h, rank: rank + v) {
                    if let occupant = board[captureLocation] {
                        if occupant.player == opponent {
                            result.append(.capture(piece: piece,
                                                   from: location,
                                                   to: captureLocation,
                                                   capturedPiece: occupant))
                        }
                    }

                    // TODO: En-passant captures
                }
            }
        }

        return AnySequence(result)
    }

    // MARK:- Knight

    static let knightJumps = [
        ( 1, 2), ( 1, -2),
        (-1, 2), (-1, -2),
        ( 2, 1), ( 2, -1),
        (-2, 1), (-2, -1)
    ]

    func generateKnightMoves(player: Player, location: Location) -> AnySequence<Move> {
        let file = location.file
        let rank = location.rank
        let piece = Piece(player, .knight)

        var result = [Move]()

        for (h, v) in Position.knightJumps {
            if let targetLocation = Location.ifValid(file: file + h, rank: rank + v) {
                if let occupant = board[targetLocation] {
                    if occupant.player != player {
                        result.append(.capture(piece: piece,
                                               from: location,
                                               to: targetLocation,
                                               capturedPiece: occupant))
                    }
                }
                else {
                    result.append(.move(piece: piece, from: location, to: targetLocation))
                }
            }
        }

        return AnySequence(result)
    }
}
