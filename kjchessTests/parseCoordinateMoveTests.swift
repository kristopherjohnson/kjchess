//
//  parseCoordinateMoveTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class parseCoordinateMoveTests: XCTestCase {

    func test_empty() {
        if let (_, _, _) = parseCoordinateMove("") {
            XCTFail("Empty string should not be parseable")
        }
    }

    func test_e() {
        if let (_, _, _) = parseCoordinateMove("e") {
            XCTFail("\"e\" should not be parseable")
        }
    }

    func test_e2() {
        if let (_, _, _) = parseCoordinateMove("e2") {
            XCTFail("\"e2\" should not be parseable")
        }
    }

    func test_e2e() {
        if let (_, _, _) = parseCoordinateMove("e2e") {
            XCTFail("\"e2e\" should not be parseable")
        }
    }

    func test_e2e4() {
        if let (from, to, promote) = parseCoordinateMove("e2e4") {
            XCTAssertEqual(e2, from)
            XCTAssertEqual(e4, to)
            XCTAssertNil(promote)
        }
        else {
            XCTFail("Unable to parse e2e4")
        }
    }

    func test_a1h8() {
        if let (from, to, promote) = parseCoordinateMove("a1h8") {
            XCTAssertEqual(a1, from)
            XCTAssertEqual(h8, to)
            XCTAssertNil(promote)
        }
        else {
            XCTFail("Unable to parse a1h8")
        }
    }

    func test_e7e8q() {
        if let (from, to, promote) = parseCoordinateMove("e7e8q") {
            XCTAssertEqual(e7, from)
            XCTAssertEqual(e8, to)
            XCTAssertEqual(PieceKind.queen, promote)
        }
        else {
            XCTFail("Unable to parse e7e8q")
        }
    }

    func test_d7d8b() {
        if let (from, to, promote) = parseCoordinateMove("d7d8b") {
            XCTAssertEqual(d7, from)
            XCTAssertEqual(d8, to)
            XCTAssertEqual(PieceKind.bishop, promote)
        }
        else {
            XCTFail("Unable to parse d7d8b")
        }
    }

    func test_b2b1n() {
        if let (from, to, promote) = parseCoordinateMove("b2b1n") {
            XCTAssertEqual(b2, from)
            XCTAssertEqual(b1, to)
            XCTAssertEqual(PieceKind.knight, promote)
        }
        else {
            XCTFail("Unable to parse b2b1n")
        }
    }

    func test_a2a1r() {
        if let (from, to, promote) = parseCoordinateMove("a2a1r") {
            XCTAssertEqual(a2, from)
            XCTAssertEqual(a1, to)
            XCTAssertEqual(PieceKind.rook, promote)
        }
        else {
            XCTFail("Unable to parse a2a1r")
        }
    }
}
