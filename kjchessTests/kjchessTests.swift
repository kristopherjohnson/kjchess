//
//  kjchessTests.swift
//  kjchessTests
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
@testable import kjchess

class kjchessTests: XCTestCase {
    
    func testInitialPosition() {
        let pos = Position.newGame()

        XCTAssertEqual(.white, pos.toMove)

        XCTAssertEqual(0, pos.moves.count)

        let b = pos.board

        XCTAssertEqual(WR, b[a1])
        XCTAssertEqual(WN, b[b1])
        XCTAssertEqual(WB, b[c1])
        XCTAssertEqual(WQ, b[d1])
        XCTAssertEqual(WK, b[e1])
        XCTAssertEqual(WB, b[f1])
        XCTAssertEqual(WN, b[g1])
        XCTAssertEqual(WR, b[h1])

        XCTAssertEqual(WP, b[a2])
        XCTAssertEqual(WP, b[b2])
        XCTAssertEqual(WP, b[c2])
        XCTAssertEqual(WP, b[d2])
        XCTAssertEqual(WP, b[e2])
        XCTAssertEqual(WP, b[f2])
        XCTAssertEqual(WP, b[g2])
        XCTAssertEqual(WP, b[h2])

        XCTAssertEqual(BR, b[a8])
        XCTAssertEqual(BN, b[b8])
        XCTAssertEqual(BB, b[c8])
        XCTAssertEqual(BQ, b[d8])
        XCTAssertEqual(BK, b[e8])
        XCTAssertEqual(BB, b[f8])
        XCTAssertEqual(BN, b[g8])
        XCTAssertEqual(BR, b[h8])

        XCTAssertEqual(BP, b[a7])
        XCTAssertEqual(BP, b[b7])
        XCTAssertEqual(BP, b[c7])
        XCTAssertEqual(BP, b[d7])
        XCTAssertEqual(BP, b[e7])
        XCTAssertEqual(BP, b[f7])
        XCTAssertEqual(BP, b[g7])
        XCTAssertEqual(BP, b[h7])

        for rank in 2...5 {
            for file in 0...7 {
                XCTAssertNil(b.at(file, rank))
            }
        }
    }

    func testBoardAfterMove() {
        let b1 = Board.newGame

        let m = Move.move(piece: WP, from: e2, to: e4)
        let b2 = b1.after(m)

        XCTAssertEqual(WP, b1[e2], "b1 should be unaffected")
        XCTAssertEqual(nil, b1[e4], "b1 should be unaffected")

        XCTAssertEqual(WP, b2[e4])
        XCTAssertEqual(nil, b2[e2])
    }

    func testBoardAfterCapture() {
        let b1 = Board.empty
            .with(WQ, at: d1)
            .with(BQ, at: d8)

        let b2 = b1.after(.capture(piece: WQ, from: d1, to: d8, capturedPiece: BQ))

        XCTAssertEqual(WQ, b1[d1], "b1 should be unaffected")
        XCTAssertEqual(BQ, b1[d8], "b1 should be unaffected")

        XCTAssertEqual(WQ, b2[d8])
        XCTAssertEqual(nil, b2[d1])
    }

    func testBoardAfterWhiteEnPassantCapture() {
        let b1 = Board.empty
            .with(WP, at: e5)
            .with(BP, at: d5)

        let b2 = b1.after(.enPassantCapture(piece: WP, from: e5, to: d6, capturedPiece: BP))

        XCTAssertEqual(WP, b1[e5], "b1 should be unaffected")
        XCTAssertEqual(BP, b1[d5], "b1 should be unaffected")

        XCTAssertEqual(WP, b2[d6])
        XCTAssertEqual(nil, b2[e5])
        XCTAssertEqual(nil, b2[d5])
    }

    func testBoardAfterBlackEnPassantCapture() {
        let b1 = Board.empty
            .with(WP, at: f4)
            .with(BP, at: g4)

        let b2 = b1.after(.enPassantCapture(piece: BP, from: g4, to: f3, capturedPiece: WP))

        XCTAssertEqual(WP, b1[f4], "b1 should be unaffected")
        XCTAssertEqual(BP, b1[g4], "b1 should be unaffected")

        XCTAssertEqual(BP, b2[f3])
        XCTAssertEqual(nil, b2[f4])
        XCTAssertEqual(nil, b2[g4])
    }

    func testBoardAfterWhiteKingsideCastling() {
        let b1 = Board.empty
            .with(WK, at: e1)
            .with(WR, at: h1)

        let b2 = b1.after(.castleKingside(player: .white))

        XCTAssertEqual(WK, b1[e1], "b1 should be unaffected")
        XCTAssertEqual(WR, b1[h1], "b1 should be unaffected")

        XCTAssertEqual(WK, b2[g1])
        XCTAssertEqual(WR, b2[f1])
        XCTAssertEqual(nil, b2[e1])
        XCTAssertEqual(nil, b2[h1])
    }

    func testBoardAfterBlackKingsideCastling() {
        let b1 = Board.empty
            .with(BK, at: e8)
            .with(BR, at: h8)

        let b2 = b1.after(.castleKingside(player: .black))

        XCTAssertEqual(BK, b1[e8], "b1 should be unaffected")
        XCTAssertEqual(BR, b1[h8], "b1 should be unaffected")

        XCTAssertEqual(BK, b2[g8])
        XCTAssertEqual(BR, b2[f8])
        XCTAssertEqual(nil, b2[e8])
        XCTAssertEqual(nil, b2[h8])
    }

    func testBoardAfterWhiteQueensideCastling() {
        let b1 = Board.empty
            .with(WK, at: e1)
            .with(WR, at: a1)

        let b2 = b1.after(.castleQueenside(player: .white))

        XCTAssertEqual(WK, b1[e1], "b1 should be unaffected")
        XCTAssertEqual(WR, b1[a1], "b1 should be unaffected")

        XCTAssertEqual(WK, b2[c1])
        XCTAssertEqual(WR, b2[d1])
        XCTAssertEqual(nil, b2[e1])
        XCTAssertEqual(nil, b2[a1])
    }

    func testBoardAfterBlackQueensideCastling() {
        let b1 = Board.empty
            .with(BK, at: e8)
            .with(BR, at: a8)

        let b2 = b1.after(.castleQueenside(player: .black))

        XCTAssertEqual(BK, b1[e8], "b1 should be unaffected")
        XCTAssertEqual(BR, b1[a8], "b1 should be unaffected")

        XCTAssertEqual(BK, b2[c8])
        XCTAssertEqual(BR, b2[d8])
        XCTAssertEqual(nil, b2[e8])
        XCTAssertEqual(nil, b2[a8])
    }
}
