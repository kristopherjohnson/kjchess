//
//  Position_legalMoves.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

extension Position {

    /// Generate sequence of legal moves for this `Position`.
    ///
    public func legalMoves() -> [Move] {
        guard let kingLocation = board.kingLocation(player: toMove) else {
            return possibleMoves()
        }

        let isInCheck = isAttacked(location: kingLocation, by: toMove.opponent)

        return possibleMoves().filter {
            isLegal(move: $0, kingLocation: kingLocation, isInCheck: isInCheck)
        }
    }

    /// Generate array of possible moves for this `Position`.
    ///
    /// The generated moves will all be valid in the sense that
    /// the piece can perform the move/capture. However, this
    /// method does not verify that the move will not leave
    /// the player's king in check or that it doesn't result
    /// in a repeated board position.
    private func possibleMoves() -> [Move] {
        let piecesLocations = board.pieces(player: toMove)

        var moves = [Move]()
        moves.reserveCapacity(200)
        for (piece, location) in piecesLocations {
            addMoves(piece: piece, location: location, to: &moves)
        }
        return moves
    }

    /// Add moves for a `Piece` at the given `Location` to an array.
    private func addMoves(piece: Piece, location: Location,
                          to moves: inout [Move]) {
        switch piece.kind {
        case .pawn:   addPawnMoves(piece: piece, location: location, to: &moves)
        case .knight: addKnightMoves(piece: piece, location: location, to: &moves)
        case .rook:   addRookMoves(piece: piece, location: location, to: &moves)
        case .bishop: addBishopMoves(piece: piece, location: location, to: &moves)
        case .queen:  addQueenMoves(piece: piece, location: location, to: &moves)
        case .king:   addKingMoves(piece: piece, location: location, to: &moves)
        }
    }

    private func addSlideMoves(piece: Piece, location: Location, vectors: [(Int, Int)],
                               to moves: inout [Move]) {
        let player = piece.player

        for (h, v) in vectors {
            var file = location.file + h
            var rank = location.rank + v
            while let targetLocation = Location.ifValid(file: file, rank: rank) {
                if let occupant = board[targetLocation] {
                    if occupant.player != player {
                        moves.append(.capture(piece: piece,
                                              from: location,
                                              to: targetLocation,
                                              captured: occupant.kind))
                    }
                    break
                }
                else {
                    moves.append(.move(piece: piece, from: location, to: targetLocation))
                    file = file + h
                    rank = rank + v
                }
            }
        }
    }

    // MARK:- Pawn

    private static let whitePawnCaptureMoves = [(-1,  1), (1,  1)]
    private static let blackPawnCaptureMoves = [(-1, -1), (1, -1)]

    private static func pawnCaptureMoves(player: Player) -> [(Int, Int)] {
        switch player {
        case .white: return whitePawnCaptureMoves
        case .black: return blackPawnCaptureMoves
        }
    }

    private static func pawnMoveDirection(player: Player) -> Int {
        switch player {
        case .white: return 1
        case .black: return -1
        }
    }

    private static func pawnPromotionRank(player: Player) -> Int {
        switch player {
        case .white: return Board.maxRank
        case .black: return Board.minRank
        }
    }

    private static func pawnStartRank(player: Player) -> Int {
        switch player {
        case .white: return Board.minRank + 1
        case .black: return Board.maxRank - 1
        }
    }

    private func addPawnMoves(piece: Piece, location: Location,
                              to moves: inout [Move]) {
        let player = piece.player
        let file = location.file
        let rank = location.rank

        if Board.minRank < rank && rank < Board.maxRank {
            let promotionRank = Position.pawnPromotionRank(player: player)
            let moveDirection = Position.pawnMoveDirection(player: player)
            let nextRank = rank + moveDirection
            if board.isEmpty(file: file, rank: nextRank) {
                let to = Location(file, nextRank)

                if to.rank == promotionRank {
                    for kind in PieceKind.promotionKinds {
                        moves.append(.promote(player: player,
                                              from: location,
                                              to: to,
                                              promoted: kind))
                    }
                }
                else {
                    moves.append(.move(piece: piece, from: location, to: to))

                    let startRank = Position.pawnStartRank(player: player)
                    if rank == startRank {
                        let jumpRank = startRank + 2 * moveDirection
                        if board.isEmpty(file: file, rank: jumpRank) {
                            moves.append(.move(piece: piece,
                                               from: location,
                                               to: Location(file, jumpRank)))
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
                            if captureLocation.rank == promotionRank {
                                for kind in PieceKind.promotionKinds {
                                    moves.append(.promoteCapture(player: player,
                                                                 from: location,
                                                                 to: captureLocation,
                                                                 captured: occupant.kind,
                                                                 promoted: kind))
                                }
                            }
                            else {
                                moves.append(.capture(piece: piece,
                                                      from: location,
                                                      to: captureLocation,
                                                      captured: occupant.kind))
                            }
                        }
                    }
                    else if let enPassantCaptureLocation = enPassantCaptureLocation,
                        captureLocation == enPassantCaptureLocation {
                        moves.append(.enPassantCapture(player: player,
                                                       from: location,
                                                       to: enPassantCaptureLocation))
                    }
                }
            }
        }
    }

    // MARK:- Knight

    private static let knightJumps = [
        ( 1, 2), ( 1, -2),
        (-1, 2), (-1, -2),
        ( 2, 1), ( 2, -1),
        (-2, 1), (-2, -1)
    ]

    private func addKnightMoves(piece: Piece, location: Location,
                                to moves: inout [Move]) {
        let file = location.file
        let rank = location.rank
        let player = piece.player

        for (h, v) in Position.knightJumps {
            if let targetLocation = Location.ifValid(file: file + h, rank: rank + v) {
                if let occupant = board[targetLocation] {
                    if occupant.player != player {
                        moves.append(.capture(piece: piece,
                                              from: location,
                                              to: targetLocation,
                                              captured: occupant.kind))
                    }
                }
                else {
                    moves.append(.move(piece: piece, from: location, to: targetLocation))
                }
            }
        }
    }

    // MARK:- Rook

    private static let rookVectors = [
        (1, 0), (-1,  0),
        (0, 1), ( 0, -1)
    ]

    private static let pieceKindsWithRookVectors: [PieceKind]
        = [.rook, .queen]

    private func addRookMoves(piece: Piece, location: Location,
                              to moves: inout [Move]) {
        addSlideMoves(piece: piece,
                      location: location,
                      vectors: Position.rookVectors,
                      to: &moves)
    }

    // MARK:- Bishop

    private static let bishopVectors = [
        (1,  1), (-1,  1),
        (1, -1), (-1, -1)
    ]

    private static let pieceKindsWithBishopVectors: [PieceKind]
        = [.bishop, .queen]

    private func addBishopMoves(piece: Piece, location: Location,
                                to moves: inout [Move]) {
        addSlideMoves(piece: piece,
                      location: location,
                      vectors: Position.bishopVectors,
                      to: &moves)
    }

    // MARK:- Queen

    private static let eightDirections = [
        (1,  0), (-1,  0),
        (0,  1), ( 0, -1),
        (1,  1), (-1,  1),
        (1, -1), (-1, -1)
    ]

    private func addQueenMoves(piece: Piece, location: Location,
                               to moves: inout [Move]) {
        addSlideMoves(piece: piece,
                      location: location,
                      vectors: Position.eightDirections,
                      to: &moves)
    }

    // MARK:- King

    private func addKingMoves(piece: Piece, location: Location,
                              to moves: inout [Move]) {
        let file = location.file
        let rank = location.rank
        let player = piece.player

        for (h, v) in Position.eightDirections {
            if let targetLocation = Location.ifValid(file: file + h, rank: rank + v) {
                if let occupant = board[targetLocation] {
                    if occupant.player != player {
                        moves.append(.capture(piece: piece,
                                               from: location,
                                               to: targetLocation,
                                               captured: occupant.kind))
                    }
                }
                else {
                    moves.append(.move(piece: piece,
                                       from: location,
                                       to: targetLocation))
                }
            }
        }
        
        switch player {
        case .white:
            if whiteCanCastleKingside &&
                board[e1] == WK &&
                board[f1] == nil &&
                board[g1] == nil &&
                board[h1] == WR
            {
                moves.append(.castleKingside(player: player))
            }

            if whiteCanCastleQueenside &&
                board[e1] == WK &&
                board[d1] == nil &&
                board[c1] == nil &&
                board[b1] == nil &&
                board[a1] == WR
            {
                moves.append(.castleQueenside(player: player))
            }

        case .black:
            if blackCanCastleKingside &&
                board[e8] == BK &&
                board[f8] == nil &&
                board[g8] == nil &&
                board[h8] == BR
            {
                moves.append(.castleKingside(player: player))
            }

            if blackCanCastleQueenside &&
                board[e8] == BK &&
                board[d8] == nil &&
                board[c8] == nil &&
                board[b8] == nil &&
                board[a8] == BR
            {
                moves.append(.castleQueenside(player: player))
            }
        }
    }

    // MARK:- Legal moves

    /// Determine whether specified move is legal given the king's position.
    private func isLegal(move: Move, kingLocation: Location, isInCheck: Bool) -> Bool {
        let from = move.from
        let opponent = move.player.opponent

        // If King moving, ensure it doesn't move into check.
        if from == kingLocation && !move.isResignation {
            if isAttacked(location: move.to, by: opponent) {
                return false
            }

            // If castling, can't be in check or move through attacked squares
            switch move {
            case .castleKingside(.white):
                if isInCheck || isAttacked(location: f1, by: opponent) {
                    return false
                }
            case .castleQueenside(.white):
                if isInCheck || isAttacked(location: d1, by: opponent) {
                    return false
                }
            case .castleKingside(.black):
                if isInCheck || isAttacked(location: f8, by: opponent) {
                    return false
                }
            case .castleQueenside(.black):
                if isInCheck || isAttacked(location: d8, by: opponent) {
                    return false
                }
            default:
                break
            }
        }
        else if isInCheck
            || from.isSameDiagonal(kingLocation)
            || from.isSameRank(kingLocation)
            || from.isSameFile(kingLocation)
        {
            // Ensure King is not left in check.
            let newPosition = after(move)
            if newPosition.isAttacked(location: kingLocation, by: opponent) {
                return false
            }
        }

        return true
    }

    /// Determine whether a given square is under attack by any of a player's pieces.
    private func isAttacked(location: Location, by player: Player) -> Bool {
        let file = location.file
        let rank = location.rank

        // Check for knight attack.
        for (h, v) in Position.knightJumps {
            if let attackerLocation = Location.ifValid(file: file + h, rank: rank + v) {
                if let attacker = board[attackerLocation] {
                    if attacker.player == player && attacker.kind == .knight {
                        return true
                    }
                }
            }
        }

        // Check for rook or queen attack along file or rank.
        for vector in Position.rookVectors {
            if isAttackedBySlide(location: location,
                                 player: player,
                                 vector: vector,
                                 kinds: Position.pieceKindsWithRookVectors) {
                return true
            }
        }

        // Check for bishop or queen attack along diagonals.
        for vector in Position.bishopVectors {
            if isAttackedBySlide(location: location,
                                 player: player,
                                 vector: vector,
                                 kinds: Position.pieceKindsWithBishopVectors) {
                return true
            }
        }

        // Check for attack by king.
        for (h, v) in Position.eightDirections {
            if let attackerLocation = Location.ifValid(file: file + h, rank: rank + v) {
                if let attacker = board[attackerLocation] {
                    if attacker.player == player && attacker.kind == .king {
                        return true
                    }
                }
            }
        }

        // Check for attack by pawn.
        for (h, v) in Position.pawnCaptureMoves(player: player) {
            if let attackerLocation = Location.ifValid(file: file - h, rank: rank - v) {
                if let attacker = board[attackerLocation] {
                    if attacker.player == player && attacker.kind == .pawn {
                        return true
                    }
                }
            }
        }

        return false
    }

    private func isAttackedBySlide(location: Location,
                                   player: Player,
                                   vector: (Int, Int),
                                   kinds: [PieceKind]) -> Bool
    {
        let (h, v) = vector
        var file = location.file + h
        var rank = location.rank + v
        while let attackerLocation = Location.ifValid(file: file, rank: rank) {
            if let attacker = board[attackerLocation] {
                if attacker.player == player {
                    return kinds.contains(attacker.kind)
                }

                return false
            }
            else {
                file = file + h
                rank = rank + v
            }
        }
        return false
    }
}
