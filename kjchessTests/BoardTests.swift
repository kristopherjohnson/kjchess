//
//  BoardTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
@testable import kjchess

func ==(_ lhs: (Piece, Location), _ rhs: (Piece, Location)) -> Bool {
    return lhs.0 == rhs.0 && lhs.1 == rhs.1
}

class BoardTests: XCTestCase {
    func testAfterMove() {
        let b1 = Board.newGame

        let b2 = b1.after(.move(piece: WP,
                                from: e2, to: e4))

        XCTAssertEqual(WP, b1[e2], "b1 should be unaffected")
        XCTAssertEqual(nil, b1[e4], "b1 should be unaffected")

        XCTAssertEqual(WP, b2[e4])
        XCTAssertEqual(nil, b2[e2])
    }

    func testApplyAndUnapplyMove() {
        let b1 = Board.newGame

        var b2 = b1

        let move = Move.move(piece: WP,
                             from: e2, to: e4)
        b2.apply(move)

        XCTAssertEqual(WP, b2[e4])
        XCTAssertEqual(nil, b2[e2])

        b2.unapply(move)

        XCTAssertEqual(b1, b2, "Should be the same after unapply()")
    }

    func testAfterCapture() {
        let b1 = Board.empty.with((WQ, d1),
                                  (BQ, d8))

        let b2 = b1.after(.capture(piece: WQ,
                                   from: d1, to: d8,
                                   captured: .queen))

        XCTAssertEqual(WQ, b1[d1], "b1 should be unaffected")
        XCTAssertEqual(BQ, b1[d8], "b1 should be unaffected")

        XCTAssertEqual(WQ, b2[d8])
        XCTAssertEqual(nil, b2[d1])
    }

    func testApplyAndUnapplyCapture() {
        let b1 = Board.empty.with((WQ, d1),
                                  (BQ, d8))

        var b2 = b1

        let move = Move.capture(piece: WQ,
                                from: d1, to: d8,
                                captured: .queen)

        b2.apply(move)

        XCTAssertEqual(WQ, b2[d8])
        XCTAssertEqual(nil, b2[d1])

        b2.unapply(move)
        XCTAssertEqual(b1, b2, "Should be the same after unapply()")
    }
    
    func testAfterWhiteEnPassantCapture() {
        let b1 = Board.empty.with((WP, e5),
                                  (BP, d5))

        let b2 = b1.after(.enPassantCapture(player: .white,
                                            from: e5, to: d6))

        XCTAssertEqual(WP, b1[e5], "b1 should be unaffected")
        XCTAssertEqual(BP, b1[d5], "b1 should be unaffected")

        XCTAssertEqual(WP, b2[d6])
        XCTAssertEqual(nil, b2[e5])
        XCTAssertEqual(nil, b2[d5])
    }

    func testApplyAndUnapplyWhiteEnPassantCapture() {
        let b1 = Board.empty.with((WP, e5),
                                  (BP, d5))

        var b2 = b1

        let move = Move.enPassantCapture(player: .white,
                                         from: e5, to: d6)

        b2.apply(move)

        XCTAssertEqual(WP, b2[d6])
        XCTAssertEqual(nil, b2[e5])
        XCTAssertEqual(nil, b2[d5])

        b2.unapply(move)
        XCTAssertEqual(b1, b2, "Should be the same after unapply()")
    }

    func testAfterBlackEnPassantCapture() {
        let b1 = Board.empty.with((WP, f4),
                                  (BP, g4))

        let b2 = b1.after(.enPassantCapture(player: .black,
                                            from: g4, to: f3))

        XCTAssertEqual(WP, b1[f4], "b1 should be unaffected")
        XCTAssertEqual(BP, b1[g4], "b1 should be unaffected")

        XCTAssertEqual(BP, b2[f3])
        XCTAssertEqual(nil, b2[f4])
        XCTAssertEqual(nil, b2[g4])
    }

    func testApplyAndUnapplyBlackEnPassantCapture() {
        let b1 = Board.empty.with((WP, f4),
                                  (BP, g4))

        var b2 = b1

        let move = Move.enPassantCapture(player: .black,
                                         from: g4, to: f3)

        b2.apply(move)

        XCTAssertEqual(BP, b2[f3])
        XCTAssertEqual(nil, b2[f4])
        XCTAssertEqual(nil, b2[g4])

        b2.unapply(move)
        XCTAssertEqual(b1, b2, "Should be the same after unapply()")
    }
    
    func testAfterWhiteKingsideCastling() {
        let b1 = Board.empty.with((WK, e1),
                                  (WR, h1))

        let b2 = b1.after(.castleKingside(player: .white))

        XCTAssertEqual(WK, b1[e1], "b1 should be unaffected")
        XCTAssertEqual(WR, b1[h1], "b1 should be unaffected")

        XCTAssertEqual(WK, b2[g1])
        XCTAssertEqual(WR, b2[f1])
        XCTAssertEqual(nil, b2[e1])
        XCTAssertEqual(nil, b2[h1])
    }

    func testApplyAndUnapplyWhiteKingsideCastling() {
        let b1 = Board.empty.with((WK, e1),
                                  (WR, h1))

        var b2 = b1

        let move = Move.castleKingside(player: .white)

        b2.apply(move)

        XCTAssertEqual(WK, b2[g1])
        XCTAssertEqual(WR, b2[f1])
        XCTAssertEqual(nil, b2[e1])
        XCTAssertEqual(nil, b2[h1])

        b2.unapply(move)
        XCTAssertEqual(b1, b2, "Should be the same after unapply()")
    }
    
    func testAfterBlackKingsideCastling() {
        let b1 = Board.empty.with((BK, e8),
                                  (BR, h8))

        let b2 = b1.after(.castleKingside(player: .black))

        XCTAssertEqual(BK, b1[e8], "b1 should be unaffected")
        XCTAssertEqual(BR, b1[h8], "b1 should be unaffected")

        XCTAssertEqual(BK, b2[g8])
        XCTAssertEqual(BR, b2[f8])
        XCTAssertEqual(nil, b2[e8])
        XCTAssertEqual(nil, b2[h8])
    }

    func testApplyAndUnapplyBlackKingsideCastling() {
        let b1 = Board.empty.with((BK, e8),
                                  (BR, h8))

        var b2 = b1

        let move = Move.castleKingside(player: .black)

        b2.apply(move)

        XCTAssertEqual(BK, b2[g8])
        XCTAssertEqual(BR, b2[f8])
        XCTAssertEqual(nil, b2[e8])
        XCTAssertEqual(nil, b2[h8])

        b2.unapply(move)
        XCTAssertEqual(b1, b2, "Should be the same after unapply()")
    }
    
    func testAfterWhiteQueensideCastling() {
        let b1 = Board.empty.with((WK, e1),
                                  (WR, a1))

        let b2 = b1.after(.castleQueenside(player: .white))

        XCTAssertEqual(WK, b1[e1], "b1 should be unaffected")
        XCTAssertEqual(WR, b1[a1], "b1 should be unaffected")

        XCTAssertEqual(WK, b2[c1])
        XCTAssertEqual(WR, b2[d1])
        XCTAssertEqual(nil, b2[e1])
        XCTAssertEqual(nil, b2[a1])
    }

    func testApplyAndUnapplyWhiteQueensideCastling() {
        let b1 = Board.empty.with((WK, e1),
                                  (WR, a1))

        var b2 = b1

        let move = Move.castleQueenside(player: .white)

        b2.apply(move)

        XCTAssertEqual(WK, b2[c1])
        XCTAssertEqual(WR, b2[d1])
        XCTAssertEqual(nil, b2[e1])
        XCTAssertEqual(nil, b2[a1])

        b2.unapply(move)
        XCTAssertEqual(b1, b2, "Should be the same after unapply()")
    }

    func testAfterBlackQueensideCastling() {
        let b1 = Board.empty.with((BK, e8),
                                  (BR, a8))

        let b2 = b1.after(.castleQueenside(player: .black))

        XCTAssertEqual(BK, b1[e8], "b1 should be unaffected")
        XCTAssertEqual(BR, b1[a8], "b1 should be unaffected")
        
        XCTAssertEqual(BK, b2[c8])
        XCTAssertEqual(BR, b2[d8])
        XCTAssertEqual(nil, b2[e8])
        XCTAssertEqual(nil, b2[a8])
    }

    func testApplyAndUnapplyBlackQueensideCastling() {
        let b1 = Board.empty.with((BK, e8),
                                  (BR, a8))

        var b2 = b1

        let move = Move.castleQueenside(player: .black)

        b2.apply(move)

        XCTAssertEqual(BK, b2[c8])
        XCTAssertEqual(BR, b2[d8])
        XCTAssertEqual(nil, b2[e8])
        XCTAssertEqual(nil, b2[a8])

        b2.unapply(move)
        XCTAssertEqual(b1, b2, "Should be the same after unapply()")
    }
    
    func testPieces() {
        let board = Board.newGame

        let whitePieces = board.pieces(player: .white)
        XCTAssertEqual(16, whitePieces.count)
        XCTAssertTrue(whitePieces.contains { $0 == (WR, a1) })
        XCTAssertTrue(whitePieces.contains { $0 == (WN, b1) })
        XCTAssertTrue(whitePieces.contains { $0 == (WB, c1) })
        XCTAssertTrue(whitePieces.contains { $0 == (WQ, d1) })
        XCTAssertTrue(whitePieces.contains { $0 == (WK, e1) })
        XCTAssertTrue(whitePieces.contains { $0 == (WB, f1) })
        XCTAssertTrue(whitePieces.contains { $0 == (WN, g1) })
        XCTAssertTrue(whitePieces.contains { $0 == (WR, h1) })

        XCTAssertTrue(whitePieces.contains { $0 == (WP, a2) })
        XCTAssertTrue(whitePieces.contains { $0 == (WP, b2) })
        XCTAssertTrue(whitePieces.contains { $0 == (WP, c2) })
        XCTAssertTrue(whitePieces.contains { $0 == (WP, d2) })
        XCTAssertTrue(whitePieces.contains { $0 == (WP, e2) })
        XCTAssertTrue(whitePieces.contains { $0 == (WP, f2) })
        XCTAssertTrue(whitePieces.contains { $0 == (WP, g2) })
        XCTAssertTrue(whitePieces.contains { $0 == (WP, h2) })

        let blackPieces = board.pieces(player: .black)
        XCTAssertEqual(16, blackPieces.count)
        XCTAssertTrue(blackPieces.contains { $0 == (BR, a8) })
        XCTAssertTrue(blackPieces.contains { $0 == (BN, b8) })
        XCTAssertTrue(blackPieces.contains { $0 == (BB, c8) })
        XCTAssertTrue(blackPieces.contains { $0 == (BQ, d8) })
        XCTAssertTrue(blackPieces.contains { $0 == (BK, e8) })
        XCTAssertTrue(blackPieces.contains { $0 == (BB, f8) })
        XCTAssertTrue(blackPieces.contains { $0 == (BN, g8) })
        XCTAssertTrue(blackPieces.contains { $0 == (BR, h8) })

        XCTAssertTrue(blackPieces.contains { $0 == (BP, a7) })
        XCTAssertTrue(blackPieces.contains { $0 == (BP, b7) })
        XCTAssertTrue(blackPieces.contains { $0 == (BP, c7) })
        XCTAssertTrue(blackPieces.contains { $0 == (BP, d7) })
        XCTAssertTrue(blackPieces.contains { $0 == (BP, e7) })
        XCTAssertTrue(blackPieces.contains { $0 == (BP, f7) })
        XCTAssertTrue(blackPieces.contains { $0 == (BP, g7) })
        XCTAssertTrue(blackPieces.contains { $0 == (BP, h7) })
    }
}
