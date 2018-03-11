//
//  SwiftParserTests.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 26-12-16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import XCTest
import SourceKittenFramework
@testable import IBAnalyzer

// swiftlint:disable line_length
class SwiftParserTests: XCTestCase {

    func testViewControllerWithoutOutletsAndActions() {
        let source = "class TestViewController: UIViewController { var button: UIButton!; func didTapButton(_ sender: UIButton) {} }"

        let expected = Class(outlets: [], actions: [], inherited: ["UIViewController"])
        XCTAssertEqual(mappingFor(contents: source), ["TestViewController": expected])
    }

    func testViewControllerWithOneOutlet() {
        let source = "class TestViewController: UIViewController { @IBOutlet weak var button: UIButton! }"
        let button = Declaration(name: "button", line: 1, column: 0)
        let expected = Class(outlets: [button], actions: [], inherited: ["UIViewController"])
        XCTAssertEqual(mappingFor(contents: source), ["TestViewController": expected])
    }

    func testNestedViewControllerWithOneOutlet() {
        let source = "class Outer { class TestViewController: UIViewController { @IBOutlet weak var button: UIButton! }}"

        let expectedOuter = Class(outlets: [], actions: [], inherited: [])
        let button = Declaration(name: "button", line: 1, column: 0)
        let expectedInner = Class(outlets: [button], actions: [], inherited: ["UIViewController"])
        XCTAssertEqual(mappingFor(contents: source), ["Outer": expectedOuter,
                                          "TestViewController": expectedInner])
    }

    func testViewControllerWithOneAction() {
        let source = "class TestViewController: UIViewController { @IBAction func didTapButton(_ sender: UIButton) {} }"

        let didTapButton = Declaration(name: "didTapButton:", line: 1, column: 0)
        let expected = Class(outlets: [], actions: [didTapButton], inherited: ["UIViewController"])
        XCTAssertEqual(mappingFor(contents: source), ["TestViewController": expected])
    }

    func testMultipleInheritance() {
        let source = "class TestViewController: UIViewController, SomeProtocol { }"

        let expected = Class(outlets: [], actions: [], inherited: ["UIViewController", "SomeProtocol"])
        XCTAssertEqual(mappingFor(contents: source), ["TestViewController": expected])
    }

    func testViewControllerWithActionInExtension() {
        let source = "class TestViewController: UIViewController {}; extension TestViewController { @IBAction func didTapButton(_ sender: UIButton) {} }"

        let didTapButton = Declaration(name: "didTapButton:", line: 1, column: 0)
        let expected = Class(outlets: [], actions: [didTapButton], inherited: ["UIViewController"])
        XCTAssertEqual(mappingFor(contents: source), ["TestViewController": expected])
    }

    private func mappingFor(contents: String) -> [String: Class] {
        let parser = SwiftParser()
        var result: [String: Class] = [:]
        do {
            try parser.mappingForContents(contents, result: &result)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        return result
    }
}
