//
//  Runner.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 29/01/2017.
//  Copyright © 2017 Arkadiusz Holko. All rights reserved.
//

import Foundation
import SourceKittenFramework

class Runner {
    let path: String
    let directoryEnumerator: DirectoryContentsEnumeratorType
    let nibParser: NibParserType
    let swiftParser: SwiftParserType
    let fileManager: FileManager

    init(path: String,
         directoryEnumerator: DirectoryContentsEnumeratorType = DirectoryContentsEnumerator(),
         nibParser: NibParserType = NibParser(),
         swiftParser: SwiftParserType = SwiftParser(),
         fileManager: FileManager = FileManager()) {
        self.path = path
        self.directoryEnumerator = directoryEnumerator
        self.nibParser = nibParser
        self.swiftParser = swiftParser
        self.fileManager = fileManager
    }

    func issues(using analyzers: [Analyzer]) throws -> [Issue] {
        var classNameToNibMap: [String: Nib] = [:]
        var classNameToClassMap: [String: Class] = [:]

        for url in try nibFiles() {
            let connections = try nibParser.mappingForFile(at: url)
            for (key, value) in connections {
                classNameToNibMap[key] = value
            }
        }

        for url in try swiftFiles() {
            try swiftParser.mappingForFile(at: url, result: &classNameToClassMap)
        }

        let configuration = AnalyzerConfiguration(classNameToNibMap: classNameToNibMap,
                                                  classNameToClassMap: classNameToClassMap,
                                                  uiKitClassNameToClassMap: uiKitClassNameToClass())

        return analyzers.flatMap { $0.issues(for: configuration) }
    }

    func nibFiles() throws -> [URL] {
        return try files().filter { $0.pathExtension == "storyboard" || $0.pathExtension == "xib"}
    }

    func swiftFiles() throws -> [URL] {
        return try files().filter { $0.pathExtension == "swift" }
    }

    fileprivate func files() throws -> [URL] {
        let url = URL(fileURLWithPath: path)
        return try directoryEnumerator.files(at: url, fileManager: fileManager)
    }
}
