//
//  RunnerTests.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 29/01/2017.
//  Copyright © 2017 Arkadiusz Holko. All rights reserved.
//

import XCTest
import SourceKittenFramework
@testable import IBAnalyzer

private class MockAnalyzer: Analyzer {
    var lastUsedConfiguration: AnalyzerConfiguration?

    func issues(for configuration: AnalyzerConfiguration) -> [Issue] {
        lastUsedConfiguration = configuration
        return []
    }
}

class RunnerTests: XCTestCase {
    func testCallsAnalyzerWithCorrectConfiguration() {
        let runner = Runner(path: "example",
                            directoryEnumerator: StubFineDirectoryContentsEnumerator(),
                            nibParser: StubNibParser(),
                            swiftParser: StubSwiftParser(),
                            fileManager: FileManager.default)

        let mockAnalyzer = MockAnalyzer()
        do {
            _ = try runner.issues(using: [mockAnalyzer])
            let configuration = mockAnalyzer.lastUsedConfiguration!

            let nibMap = StubNibParser.cMap.merging(other: StubNibParser.dMap)
            XCTAssertEqual(configuration.classNameToNibMap, nibMap)

            let swiftMap = StubSwiftParser.aMap.merging(other: StubSwiftParser.eMap)
            XCTAssertEqual(configuration.classNameToClassMap, swiftMap)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

class RunnerFilesTests: XCTestCase {

    func testNibFiles() {
        let runner = Runner(path: "example", directoryEnumerator: StubFineDirectoryContentsEnumerator())
        XCTAssertEqual(try runner.nibFiles(), ["c.xib", "d.storyboard"].map { URL(fileURLWithPath: $0) })
    }

    func testSwiftFiles() {
        let runner = Runner(path: "example", directoryEnumerator: StubFineDirectoryContentsEnumerator())
        XCTAssertEqual(try runner.swiftFiles(), ["a.swift", "e.swift"].map { URL(fileURLWithPath: $0) })
    }

    func testNibFilesThrows() {
        let runner = Runner(path: "example", directoryEnumerator: StubThrowingDirectoryContentsEnumerator())
        XCTAssertThrowsError(try runner.nibFiles())
    }

    func testSwiftFilesThrows() {
        let runner = Runner(path: "example", directoryEnumerator: StubThrowingDirectoryContentsEnumerator())
        XCTAssertThrowsError(try runner.swiftFiles())
    }
}

private extension Dictionary {
    func merging(other: [Key: Value]) -> [Key: Value] {
        var mutableCopy = self
        for (key, value) in other {
            // If both dictionaries have a value for same key, the value of the other dictionary is used.
            mutableCopy[key] = value
        }
        return mutableCopy
    }
}
