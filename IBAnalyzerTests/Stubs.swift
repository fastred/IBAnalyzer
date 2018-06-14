//
//  Stubs.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 29/01/2017.
//  Copyright © 2017 Arkadiusz Holko. All rights reserved.
//

import Foundation
@testable import IBAnalyzer

struct StubFineDirectoryContentsEnumerator: DirectoryContentsEnumeratorType {
    func files(at url: URL, fileManager: FileManager) throws -> [URL] {
        return ["a.swift", "b.m", "c.xib", "d.storyboard", "e.swift", "f.swift2"].map {
            URL(fileURLWithPath: $0)
        }
    }
}

struct StubThrowingDirectoryContentsEnumerator: DirectoryContentsEnumeratorType {
    func files(at url: URL, fileManager: FileManager) throws -> [URL] {
        throw NSError(domain: "test", code: 0, userInfo: nil)
    }
}

struct StubNibParser: NibParserType {
    static let button = Declaration(name: "button", line: 1, column: 0)
    static let label = Declaration(name: "label", line: 1, column: 0)
    static let cMap = ["C": Nib(outlets: [StubNibParser.label, StubNibParser.button], actions: [])]
    static let tappedButton = Declaration(name: "tappedButton:", line: 1, column: 0)
    static let titleView = Declaration(name: "titleView", line: 1, column: 0)
    static let dMap = ["FirstViewController": Nib(outlets: [], actions: [StubNibParser.tappedButton]),
                       "SecondViewController": Nib(outlets: [StubNibParser.titleView], actions: [])]

    func mappingForFile(at url: URL) throws -> [String: Nib] {
        switch url {
        case URL(fileURLWithPath: "c.xib"):
            return type(of: self).cMap
        case URL(fileURLWithPath: "d.storyboard"):
            return type(of: self).dMap
        default:
            fatalError()
        }
    }
}

struct StubSwiftParser: SwiftParserType {
    static let label = Declaration(name: "label", line: 1, column: 0)
    static let aMap = ["C": Class(outlets: [StubSwiftParser.label], actions: [], inherited: [])]
    static let buttonTapped = Declaration(name: "buttonTapped:", line: 1, column: 0)
    static let eMap = ["FirstViewController": Class(outlets: [], actions: [StubSwiftParser.buttonTapped], inherited: [])]

    func mappingForFile(at url: URL, result: inout [String: Class]) throws {
        switch url {
        case URL(fileURLWithPath: "a.swift"):
            result += type(of: self).aMap
        case URL(fileURLWithPath: "e.swift"):
            result += type(of: self).eMap
        default:
            fatalError()
        }
    }

    func mappingForContents(_ contents: String, result: inout [String: Class]) throws {
        //do nothing
    }
}

func += <K, V> (left: inout [K: V], right: [K: V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}
