//
//  CommandLine.swift
//  SwiftDraw
//
//  Created by Simon Whitty on 23/11/18.
//  Copyright 2018 Simon Whitty
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/swhitty/SwiftDraw
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

import Foundation
import SwiftDraw

struct CommandLine {

    var directory: URL

    init(directory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)) {
        self.directory = directory
    }

    func run(with args: [String] = Swift.CommandLine.arguments) -> ExitCode {
        guard let config = try? parseConfiguration(from: args) else {
            print("Invalid Syntax. Expects: swiftdraw <filename> format")
            return .error
        }

        guard let data = try? process(with: config) else {
            print("Process failed \(config)")
            return .error
        }

        print("Data: \(data.count)")
        return .ok
    }

    func process(with config: Configuration) throws -> Data {
        guard
            let svg = SwiftDraw.Image(fileURL: config.inputSVG),
            let data = svg.pngData() else {
            throw Error.invalid
        }

        return data
    }

    func parseConfiguration(from args: [String]) throws -> Configuration {
        guard args.count >= 3 else {
            throw Error.invalid
        }

        let url = directory.appendingPathComponent(args[1])

        guard let format = Format(rawValue: args[2])else {
            throw Error.invalid
        }

        return Configuration(inputSVG: url, format: format)
    }
}

extension CommandLine {

    struct Configuration {
        var inputSVG: URL
        var format: Format
    }

    enum Format: String {
        case png
        case jpeg
    }

    enum Error: Swift.Error {
        case invalid
    }

    // Represents the exit codes to the command line. See `man sysexits` for more information.
    enum ExitCode: Int32 {
        case ok = 0 // EX_OK
        case error = 70 // EX_SOFTWARE
    }
}