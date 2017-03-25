//
//  NotationTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
@testable import kjchess

class NotationTests: XCTestCase {

    func testPawnMove() {
        let move = Move.move(piece: WP, from: e2, to: e4)
        XCTAssertEqual("WPe2-e4", move.description)
        XCTAssertEqual("e2-e4",   move.longAlgebraicForm)
        XCTAssertEqual("e2e4",    move.coordinateForm)
    }

    func testPieceMove() {
        let move = Move.move(piece: BQ, from: e8, to: b6)
        XCTAssertEqual("BQe8-b6", move.description)
        XCTAssertEqual("Qe8-b6",  move.longAlgebraicForm)
        XCTAssertEqual("e8b6",    move.coordinateForm)
    }

    func testPawnCapture() {
        let move = Move.capture(piece: WP, from: e4, to: d5, captured: .pawn)
        XCTAssertEqual("WPe4xPd5", move.description)
        XCTAssertEqual("e4xd5",    move.longAlgebraicForm)
        XCTAssertEqual("e4d5",     move.coordinateForm)
    }

    func testPieceCapture() {
        let move = Move.capture(piece: BQ, from: a8, to: h1, captured: .rook)
        XCTAssertEqual("BQa8xRh1", move.description)
        XCTAssertEqual("Qa8xh1",   move.longAlgebraicForm)
        XCTAssertEqual("a8h1",     move.coordinateForm)
    }

    func testPawnPromoteQueen() {
        let move = Move.promote(player: .white, from: e7, to: e8, promoted: .queen)
        XCTAssertEqual("WPe7-e8Q", move.description)
        XCTAssertEqual("e7-e8Q",   move.longAlgebraicForm)
        XCTAssertEqual("e7e8q",    move.coordinateForm)
    }

    func testPawnPromoteKnight() {
        let move = Move.promote(player: .black, from: d2, to: d1, promoted: .knight)
        XCTAssertEqual("BPd2-d1N", move.description)
        XCTAssertEqual("d2-d1N",   move.longAlgebraicForm)
        XCTAssertEqual("d2d1n",    move.coordinateForm)
    }

    func testPawnPromoteCapture() {
        let move = Move.promoteCapture(player: .white, from: c7, to: c8, captured: .bishop, promoted: .queen)
        XCTAssertEqual("WPc7xBc8Q", move.description)
        XCTAssertEqual("c7xc8Q",    move.longAlgebraicForm)
        XCTAssertEqual("c7c8q",     move.coordinateForm)
    }

    func testEnPassantCapture() {
        let move = Move.enPassantCapture(player: .black, from: d4, to: c3)
        XCTAssertEqual("BPd4xPc3e.p.", move.description)
        XCTAssertEqual("dxc3e.p.",     move.longAlgebraicForm)
        XCTAssertEqual("d4c3",         move.coordinateForm)
    }

    func testCastleKingsideWhite() {
        let move = Move.castleKingside(player: .white)
        XCTAssertEqual("W O-O", move.description)
        XCTAssertEqual("O-O",   move.longAlgebraicForm)
        XCTAssertEqual("e1g1",  move.coordinateForm)
    }

    func testCastleKingsideBlack() {
        let move = Move.castleKingside(player: .black)
        XCTAssertEqual("B O-O", move.description)
        XCTAssertEqual("O-O",   move.longAlgebraicForm)
        XCTAssertEqual("e8g8",  move.coordinateForm)
    }

    func testCastleQueensideWhite() {
        let move = Move.castleQueenside(player: .white)
        XCTAssertEqual("W O-O-O", move.description)
        XCTAssertEqual("O-O-O",   move.longAlgebraicForm)
        XCTAssertEqual("e1c1",    move.coordinateForm)
    }

    func testCastleQueensideBlack() {
        let move = Move.castleQueenside(player: .black)
        XCTAssertEqual("B O-O-O", move.description)
        XCTAssertEqual("O-O-O",   move.longAlgebraicForm)
        XCTAssertEqual("e8c8",    move.coordinateForm)
    }
}
