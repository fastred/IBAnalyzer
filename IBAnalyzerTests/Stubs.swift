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
    static let cMap = ["C": Nib(outlets: ["label", "button"], actions: [])]
    static let dMap = ["FirstViewController": Nib(outlets: [], actions: ["tappedButton:"]),
                       "SecondViewController": Nib(outlets: ["titleView"], actions: [])]

    func mappingForFile(at url: URL) throws -> [String : Nib] {
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
    static let aMap = ["C": Class(outlets: ["label"], actions: [], inherited: [])]
    static let eMap = ["FirstViewController": Class(outlets: [], actions: ["buttonTapped:"], inherited: [])]

    func mappingForFile(at url: URL) throws -> [String: Class] {
        switch url {
        case URL(fileURLWithPath: "a.swift"):
            return type(of: self).aMap
        case URL(fileURLWithPath: "e.swift"):
            return type(of: self).eMap
        default:
            fatalError()
        }
    }

    func mappingForContents(_ contents: String) -> [String: Class] {
        return [:]
    }
}
