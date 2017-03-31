//
//  UCIEngine.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation
import os.log

/// Implementation of UCI (Universal Chess Interface) protocol.
/// Includes a few non-standard extensions that are useful for debugging.
public class UCIEngine {

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

    /// Read UCI commands and process them until "quit" or end-of-stream.
    public func runCommandLoop() throws {
        if isLogEnabled { os_log("Enter runCommandLoop()", log: uciLog) }

        while let line = getLine() {
            let cmdTokens = tokens(line)
            if !processCommand(tokens: cmdTokens) {
                break
            }
        }

        if isLogEnabled { os_log("Exit runCommandLoop()", log: uciLog) }
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
        if isDebugEnabled { putInfoLine("Ignoring command \(tokens)") }
    }

    private func onPositionCommand(tokens: [String]) {
        if isDebugEnabled { putInfoLine("Ignoring command \(tokens)") }
    }

    private func onGoCommand(tokens: [String]) {
        if isDebugEnabled { putInfoLine("Ignoring command \(tokens)") }
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