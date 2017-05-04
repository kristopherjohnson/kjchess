//
//  FENTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class FENTests: XCTestCase {

    func testRejectEmptyFEN() {
        do {
            let fen = ""

            let _ = try Position(fen: fen)

            XCTFail("Empty FEN should cause an error to be thrown")
        }
        catch (let error) {
            XCTAssertEqual("FEN string does not have six fields: \"\"",
                           error.localizedDescription)
        }
    }

    func testInitialGameFEN() {
        do {
            let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

            let pos = try Position(fen: fen)

            XCTAssertEqual(pos, Position.newGame())

            XCTAssertEqual(fen, pos.fen)
        }
        catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }

    func testFENAfter_e4() {
        do {
            let fen = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"

            let pos = try Position(fen: fen)

            let expectedPosition = Position.newGame()
                .after(Move.move(piece: WP, from: e2, to: e4))

            XCTAssertEqual(pos, expectedPosition)

            XCTAssertEqual(fen, pos.fen)
        }
        catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }

    func testFENAfter_e4_c5() {
        do {
            let fen = "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2"

            let pos = try Position(fen: fen)

            let expectedPosition = Position.newGame()
                .after(Move.move(piece: WP, from: e2, to: e4))
                .after(Move.move(piece: BP, from: c7, to: c5))

            XCTAssertEqual(pos, expectedPosition)

            XCTAssertEqual(fen, pos.fen)
        }
        catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }

    func testFENAfter_e4_c5_Nf3() {
        do {
            let fen = "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2"

            let pos = try Position(fen: fen)

            let expectedPosition = Position.newGame()
                .after(Move.move(piece: WP, from: e2, to: e4))
                .after(Move.move(piece: BP, from: c7, to: c5))
                .after(Move.move(piece: WN, from: g1, to: f3))

            XCTAssertEqual(pos, expectedPosition)

            XCTAssertEqual(fen, pos.fen)
        }
        catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }
}
