//
//  UCIEngine.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation
import os.log
import QuartzCore

/// Implementation of UCI (Universal Chess Interface) protocol.
/// Includes a few non-standard extensions that are useful for debugging.
public class UCIEngine {

    public private(set) var position = Position.newGame()

    /// Search depth used when determining best move.
    ///
    /// A search depth of 4 provides moves in a few seconds on
    /// an Early 2013 MacBook Pro.
    public var searchDepth = 4
    
    /// Function called to read a line of input.
    ///
    /// By default, this reads a line from standard input.
    ///
    /// It can be set to another function to obtain input by
    /// other means.
    public var getLine: () -> String? = {
        if let line = readLine(strippingNewline: true) {
            if isLogEnabled { os_log("Read: %{public}@", log: uciLog, line) }
            return line
        }
        else {
            return nil
        }
    }

    /// Function called to write a line of output.
    ///
    /// By default, this writes to standard output.
    ///
    /// It can be set to another function to send output by
    /// other means.
    public var putLine: (String) -> () = { line in
        if isLogEnabled { os_log("Write: %{public}@", log: uciLog, line) }
        print(line)
    }

    /// If true, emit diagnostic output to the client.
    public var isDebugEnabled: Bool = false

    /// Initializer
    public init() {

    }

    /// Read UCI commands and process them until "quit" or end-of-stream.
    public func runCommandLoop() throws {
        if isLogEnabled { os_log("Enter runCommandLoop()", log: uciLog) }

        while let line = getLine() {
            if !processInput(line) {
                break
            }
        }

        if isLogEnabled { os_log("Exit runCommandLoop()", log: uciLog) }
    }

    /// Process a line of input.
    ///
    /// This is invoked by `runCommandLoop()` for each line of input.
    /// It may be called directly to "push" input to the engine instead
    /// of using `runCommandLoop()`.
    public func processInput(_ line: String) -> Bool {
        return processCommand(tokens: line.whitespaceSeparatedTokens())
    }

    /// Process the given command.
    ///
    /// - returns: `false` if the command loop should exit. `true` if it should continue.
    public func processCommand(tokens: [String]) -> Bool {
        if tokens.count == 0 {
            return true
        }

        let cmd = tokens[0]

        if isLogEnabled { os_log("Command: %{public}@", log: uciLog, "\(tokens)") }

        switch cmd {

        case "uci":
            onUCICommand(tokens: tokens)

        case "debug":
            onDebugCommand(tokens: tokens)

        case "isready":
            putLine("readyok")

        case "setoption":
            onSetOptionCommand(tokens: tokens)

        case "register":
            onRegisterCommand(tokens: tokens)

        case "ucinewgame":
            onNewGameCommand(tokens: tokens)

        case "position":
            onPositionCommand(tokens: tokens)

        case "go":
            onGoCommand(tokens: tokens)

        case "stop":
            onStopCommand(tokens: tokens)

        case "ponderhit":
            onPonderHitCommand(tokens: tokens)

        case "quit":
            return false

        default:
            putInfoLine("unexpected command \(cmd)")
        }

        return true
    }

    private func onUCICommand(tokens: [String]) {
        putLine("id name kjchess")
        putLine("id author Kristopher Johnson")
        putLine("uciok")
    }

    private func onDebugCommand(tokens: [String]) {
        if tokens.count > 1 {
            switch tokens[1] {

            case "on":
                isDebugEnabled = true

            case "off":
                isDebugEnabled = false

            default:
                if isDebugEnabled { putInfoLine("Unrecognized argument: \(tokens)") }
            }
        }
        else if isDebugEnabled {
            putInfoLine("Missing argument to debug command")
        }
    }

    private func onSetOptionCommand(tokens: [String]) {
        if isDebugEnabled { putInfoLine("Ignoring command \(tokens)") }
    }

    private func onRegisterCommand(tokens: [String]) {
        if isDebugEnabled { putInfoLine("Ignoring command \(tokens)") }
    }

    private func onNewGameCommand(tokens: [String]) {
        position = Position.newGame()
    }

    /// Parse a "position" command.
    ///
    /// Syntax: `position [fen <fenstring> | startpos ]  moves <move1> .... <movei>`
    private func onPositionCommand(tokens: [String]) {
        if tokens.count < 2 {
            if isLogEnabled { os_log("Missing tokens after \"position\"", log: uciLog, type: .error) }
            return
        }

        if tokens[1] == "startpos" {
            // position startpos  moves <move1> ... <moveN>
            if tokens.count < 3 || tokens[2] != "moves" {
                if isLogEnabled {
                    os_log("Missing tokens after \"startpos\"", log: uciLog, type: .error)
                }
                return
            }

            position = Position.newGame()

            for i in 3..<tokens.count {
                do {
                    let newPosition = try position.after(coordinateMove: tokens[i])
                    position = newPosition
                    if isDebugEnabled {
                        putLine("Applied move \(tokens[i])")
                    }
                }
                catch (let error) {
                    if isLogEnabled {
                        os_log("\"position\" error: move %{public}@: %{public}@",
                               log: uciLog,
                               type: .error,
                               tokens[i],
                               error.localizedDescription)
                    }
                }
            }
        }
        else if tokens[1] == "fen" {
            if tokens.count < 8 {
                if isLogEnabled {
                    os_log("\"position fen\" error: not enough elements", log: uciLog)
                    return
                }
            }
            let fenrecord = tokens[2...7].joined(separator: " ")

            do {
                position = try Position(fen: fenrecord)
            }
            catch (let error) {
                if isLogEnabled {
                    os_log("\"position fen\" error: \"%{public}@\": %{public}@",
                           log: uciLog,
                           type: .error,
                           fenrecord,
                           error.localizedDescription)
                }
            }

            // TODO: If "move" follows FEN string, process it
        }
        else {
            if isLogEnabled {
                os_log("Only \"position startpos\" is supported",
                       log: uciLog, type: .error)
            }
        }

        if isLogEnabled {
            os_log("Position: %{public}@", log: uciLog, position.description)
        }
    }

    private func onGoCommand(tokens: [String]) {
        // TODO: look at the additional tokens.  For now, we immediately return a bestmove.

        let startTime = CACurrentMediaTime()
        if let (move, score, pv) = bestMove(position: position, searchDepth: searchDepth) {
            let endTime = CACurrentMediaTime()
            let searchTimeMs = Int(((endTime - startTime) * 1000.0).rounded())

            // score could be +/-Infinity, so clamp it before converting to centipawns.
            let clampedScore = min(30000.0, max(-30000.0, score))
            let scoreCentipawns = Int((clampedScore * 100).rounded())

            var pvString: String
            if pv.count > 0 {
                pvString = pv.map{ $0.coordinateForm }.joined(separator: " ")
            }
            else {
                pvString = move.coordinateForm
            }

            putLine("info depth \(searchDepth) score cp \(scoreCentipawns) time \(searchTimeMs) pv \(pvString)")
            putLine("bestmove \(move.coordinateForm)")
        }
        else {
            putLine("bestmove 0000")
        }
    }

    private func onStopCommand(tokens: [String]) {
        if isDebugEnabled { putInfoLine("Ignoring command \(tokens)") }
    }

    private func onPonderHitCommand(tokens: [String]) {
        if isDebugEnabled { putInfoLine("Ignoring command \(tokens)") }
    }

    private func putInfoLine(_ s: String) {
        if isLogEnabled { os_log("Info: %{public}@", log: uciLog, s) }

        putLine("info string \(s)")
    }
}
