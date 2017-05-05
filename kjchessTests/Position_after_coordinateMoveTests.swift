//
//  Position_after_coordinateMoveTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class Position_after_coordinateMoveTests: XCTestCase {

    func test_e2e4() {
        do {
            let pos = try Position.newGame().after(
                coordinateMove: "e2e4");

            let expectedPosition = Position.newGame().after(
                .move(piece: WP, from: e2, to: e4))
            XCTAssertEqual(expectedPosition, pos)
        }
        catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }

    func test_e7e5() {
        do {
            let pos = try Position.newGame().after(
                coordinateMove: "e2e4").after(
                    coordinateMove: "e7e5")

            let expectedPosition = Position.newGame().after(
                .move(piece: WP, from: e2, to: e4)).after(
                    .move(piece: BP, from: e7, to: e5))
            XCTAssertEqual(expectedPosition, pos)
        }
        catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }

    func test_e7e8q() {
        let initialBoard = Board.empty.with(WP, e7)
        let initialPos = Position(board: initialBoard, toMove: .white)

        do {
            let pos = try initialPos.after(coordinateMove: "e7e8q")

            let brd = pos.board
            XCTAssertEqual(WQ, brd[e8])
            XCTAssertNil(brd[e7])
        }
        catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }

    func test_e7e8n() {
        let initialBoard = Board.empty.with(WP, e7)
        let initialPos = Position(board: initialBoard, toMove: .white)

        do {
            let pos = try initialPos.after(coordinateMove: "e7e8n")

            let brd = pos.board
            XCTAssertEqual(WN, brd[e8])
            XCTAssertNil(brd[e7])
        }
        catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testReject_e2e5() {
        do {
            _ = try Position.newGame().after(
                coordinateMove: "e2e5");

            XCTFail("e2e5 should throw an error");
        }
        catch (let error) {
            XCTAssertEqual("e2e5 is not valid from this position",
                           error.localizedDescription)
        }
    }

    func testReject_e7e8_nopromote() {
        let initialBoard = Board.empty.with(WP, e7)
        let initialPos = Position(board: initialBoard, toMove: .white)

        do {
            _ = try initialPos.after(coordinateMove: "e7e8")
            XCTFail("e7e8 is not valid for a pawn without specifying promoted piece")
        }
        catch (let error) {
            XCTAssertEqual("e7e8 is not valid from this position",
                           error.localizedDescription)
        }
    }

    func testReject_e6e8q() {
        let initialBoard = Board.empty.with(WP, e6)
        let initialPos = Position(board: initialBoard, toMove: .white)

        do {
            _ = try initialPos.after(coordinateMove: "e6e8q")
            XCTFail("e6e8q is not valid")
        }
        catch (let error) {
            XCTAssertEqual("e6e8q is not valid from this position",
                           error.localizedDescription)
        }
    }
}
