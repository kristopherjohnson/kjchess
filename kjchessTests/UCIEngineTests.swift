//
//  UCIEngineTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class LineStream {
    private var queue = DispatchQueue(label: "LineStream")
    private var semaphore = DispatchSemaphore(value: 0)
    private var lines = [String]()

    public func putLine(_ line: String) {
        queue.sync {
            lines.append(line)
            semaphore.signal()
        }
    }

    /// - todo: Needs a timeout to prevent blocking forever.
    public func readLine() -> String? {
        let timeout = DispatchTime.now() + 5  // No test should take this long
        if semaphore.wait(timeout: timeout) == DispatchTimeoutResult.timedOut {
            XCTFail("readLine() timed out")
        }
        var result: String? = nil
        queue.sync {
            if lines.count > 0 {
                result = lines[0]
                lines.remove(at: 0)
            }
            else {
                semaphore.signal()
            }
        }
        return result
    }
}

class UCIEngineTests: XCTestCase {

    var engine: UCIEngine?

    // Synchronizes input sent to the engine
    var toEngineQueue: DispatchQueue?

    var fromEngineStream: LineStream?

    override func setUp() {
        super.setUp()

        toEngineQueue = DispatchQueue(label: "UCIEngineTestsInput")

        fromEngineStream = LineStream()

        engine = UCIEngine()
        engine!.putLine = { self.fromEngineStream?.putLine($0) }
    }
    
    override func tearDown() {
        engine = nil
        toEngineQueue = nil
        fromEngineStream = nil

        super.tearDown()
    }

    func send(_ lines: String...) {
        for line in lines {
            toEngineQueue?.async {
                let _ = self.engine?.processInput(line)
            }
        }
    }

    func readLine() -> String? {
        return fromEngineStream?.readLine()
    }

    func expect(_ lines: String...) {
        for line in lines {
            if let r = readLine() {
                XCTAssertEqual(r, line)
            }
            else {
                XCTFail("EOF when expecting \"\(line)\"")
            }
        }
    }

    // MARK:- Tests

    func testUciInitialization() {
        send(
            "uci"
        )

        expect(
            "id name kjchess",
            "id author Kristopher Johnson",
            "uciok"
        )
    }

    func testIsReady() {
        send(
            "isready"
        )

        expect(
            "readyok"
        )
    }

    func testNewGame() {
        send(
            "ucinewgame"
        )

        XCTAssertEqual(Position.newGame(), engine!.position)
    }

    func testPositionAfter_e2e4() {
        // Note: A real GUI wouldn't send "isready" after
        // a a "position" command, but we need to make sure
        // we wait until the engine processes the command
        // asynchronously before checking the result.

        send(
            "position startpos moves e2e4",
            "isready"
        )

        expect(
            "readyok"
        )
        
        let expectedPosition = Position.newGame().after(
            .move(piece: WP, from: e2, to: e4))
        XCTAssertEqual(expectedPosition, engine!.position)
    }

    func testPlayBlackFirstMoves() {
        send(
            "position startpos moves e2e4",
            "go wtime 300000 btime 300000 movestogo 40"
        )
        
        expect(
            "bestmove e7e5"
        )
    }

    func testPlayBlackSecondMove() {
        send(
            "position startpos moves e2e4 e7e5 g1f3",
            "go wtime 297440 btime 299890 movestogo 39"
        )

        expect(
            "bestmove b8c6"
        )
    }
}
