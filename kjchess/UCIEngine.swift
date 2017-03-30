//
//  UCIEngine.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Implementation of UCI (Universal Chess Interface) protocol.
/// Includes a few non-standard extensions that are useful for debugging.
public class UCIEngine {

    /// Function called to read a line of input.
    ///
    /// By default, this reads a line from standard input.
    public var getLine: () -> String?
        = { readLine(strippingNewline: true) }

    /// Function called to write a line of output.
    ///
    /// By default, this writes to standard output.
    public var putLine: (String) -> ()
        = { print($0) }

    /// If true, emit diagnostics.
    public var debug: Bool = false

    /// Read UCI commands and process them until "quit" or end-of-stream.
    public func runCommandLoop() throws {
        while let line = getLine() {
            let cmdTokens = tokens(line)
            if !processCommand(tokens: cmdTokens) {
                return
            }
        }
    }

    /// Split an input line into tokens.
    ///
    /// Arbitrary whitespace between tokens is allowed.
    public func tokens(_ line: String) -> [String] {
        return line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    }

    /// Process the given command.
    ///
    /// - returns: `false` if the command loop should exit. `true` if it should continue.
    public func processCommand(tokens: [String]) -> Bool {
        if tokens.count == 0 {
            return true
        }

        let cmd = tokens[0]

        switch cmd {

        case "uci":
            putLine("id name kjchess")
            putLine("id author Kristopher Johnson")
            putLine("uciok")

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
            writeInfo("Unexpected command \(cmd)")
        }

        return true
    }

    private func onDebugCommand(tokens: [String]) {
        if tokens.count > 1 {
            switch tokens[1] {
            case "on":
                debug = true
                writeInfo("debug on")
            case "off":
                debug = false
            default:
                if debug {
                    writeInfo("Unrecognized argument: \(tokens)")
                }
            }
        }
        else if debug {
            writeInfo("Missing argument to debug command")
        }
    }

    private func onSetOptionCommand(tokens: [String]) {
        if debug {
            writeInfo("Ignoring command \(tokens)")
        }
    }

    private func onRegisterCommand(tokens: [String]) {
        if debug {
            writeInfo("Ignoring command \(tokens)")
        }
    }

    private func onNewGameCommand(tokens: [String]) {
        if debug {
            writeInfo("Ignoring command \(tokens)")
        }
    }

    private func onPositionCommand(tokens: [String]) {
        if debug {
            writeInfo("Ignoring command \(tokens)")
        }
    }

    private func onGoCommand(tokens: [String]) {
        if debug {
            writeInfo("Ignoring command \(tokens)")
        }
    }

    private func onStopCommand(tokens: [String]) {
        if debug {
            writeInfo("Ignoring command \(tokens)")
        }
    }

    private func onPonderHitCommand(tokens: [String]) {
        if debug {
            writeInfo("Ignoring command \(tokens)")
        }
    }

    private func writeInfo(_ s: String) {
        putLine("info string \(s)")
    }
}
