//
//  NibParserTests.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 27-12-16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import XCTest
@testable import IBAnalyzer

class NibParserTests: XCTestCase {

    func testExampleStoryboard() {
        guard let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"] else {
            fatalError("SRCROOT should be non-nil")
        }

        let path = "/IBAnalyzerTests/Examples/Example.storyboard"
        let storyboardPath = (srcRoot as NSString).appendingPathComponent(path)
        let url = URL(fileURLWithPath: storyboardPath)
        let parser = NibParser()
        let expected = ["ViewController": Nib(outlets: ["button", "titleLabel"], actions: ["didTapButton:"]),
             "ViewController2": Nib(outlets: [], actions: [])]
        do {
            let result = try parser.mappingForFile(at: url)
            XCTAssertEqual(result, expected)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}
