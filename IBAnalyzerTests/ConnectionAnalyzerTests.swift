//
//  ConnectionAnalyzerTests.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 14/01/2017.
//  Copyright © 2017 Arkadiusz Holko. All rights reserved.
//

import XCTest
@testable import IBAnalyzer

extension ConnectionIssue: Equatable {
    public static func == (lhs: ConnectionIssue, rhs: ConnectionIssue) -> Bool {
        // Not pretty but probably good enough for tests.
        return String(describing: lhs) == String(describing: rhs)
    }
}

class ConnectionAnalyzerTests: XCTestCase {
    func testNoOutletsAndActions() {
        let nib = Nib(outlets: [], actions: [])
        let klass = Class(outlets: [], actions: [], inherited: [])
        let configuration = AnalyzerConfiguration(classNameToNibMap: ["A": nib],
                                                  classNameToClassMap: ["A": klass])
        XCTAssertEqual(issues(for: configuration), [])
    }

    func testMissingOutlet() {
        let label = Declaration(name: "label", line: 1, column: 0)
        let nib = Nib(outlets: [label], actions: [])
        let klass = Class(outlets: [], actions: [], inherited: [])
        let configuration = AnalyzerConfiguration(classNameToNibMap: ["A": nib],
                                                  classNameToClassMap: ["A": klass])
        XCTAssertEqual(issues(for: configuration), [ConnectionIssue.missingOutlet(className: "A", outlet: label)])
    }

    func testMissingAction() {
        let didTapButton = Declaration(name: "didTapButton:", line: 1, column: 0)
        let nib = Nib(outlets: [], actions: [didTapButton])
        let klass = Class(outlets: [], actions: [], inherited: [])
        let configuration = AnalyzerConfiguration(classNameToNibMap: ["A": nib],
                                                  classNameToClassMap: ["A": klass])
        XCTAssertEqual(issues(for: configuration),
                       [ConnectionIssue.missingAction(className: "A", action: didTapButton)])
    }

    func testUnnecessaryOutlet() {
        let nib = Nib(outlets: [], actions: [])
        let label = Declaration(name: "label", line: 1, column: 0)
        let klass = Class(outlets: [label], actions: [], inherited: [])
        let configuration = AnalyzerConfiguration(classNameToNibMap: ["A": nib],
                                                  classNameToClassMap: ["A": klass])
        XCTAssertEqual(issues(for: configuration),
                       [ConnectionIssue.unnecessaryOutlet(className: "A", outlet: label)])
    }

    func testUnnecessaryAction() {
        let nib = Nib(outlets: [], actions: [])
        let didTapButton = Declaration(name: "didTapButton:", line: 1, column: 0)
        let klass = Class(outlets: [], actions: [didTapButton], inherited: [])
        let configuration = AnalyzerConfiguration(classNameToNibMap: ["A": nib],
                                                  classNameToClassMap: ["A": klass])
        XCTAssertEqual(issues(for: configuration),
                       [ConnectionIssue.unnecessaryAction(className: "A", action: didTapButton)])
    }

    func testNoIssueWhenOutletInSuperClass() {
        let label = Declaration(name: "label", line: 1, column: 0)
        let nib = Nib(outlets: [label], actions: [])
        let map = ["A": Class(outlets: [label], actions: [], inherited: []),
                   "B": Class(outlets: [], actions: [], inherited: ["A"])]
        let configuration = AnalyzerConfiguration(classNameToNibMap: ["B": nib],
                                                  classNameToClassMap: map)
        XCTAssertEqual(issues(for: configuration), [])
    }

    func testNoIssueWhenOutletInSuperSuperClass() {
        let label = Declaration(name: "label", line: 1, column: 0)
        let nib = Nib(outlets: [label], actions: [])
        let map = ["A": Class(outlets: [label], actions: [], inherited: []),
                   "B": Class(outlets: [], actions: [], inherited: ["A"]),
                   "C": Class(outlets: [], actions: [], inherited: ["B"])]
        let configuration = AnalyzerConfiguration(classNameToNibMap: ["C": nib],
                                                  classNameToClassMap: map)
        XCTAssertEqual(issues(for: configuration), [])
    }

    func testNoIssueWhenActionInSuperClass() {
        let didTapButton = Declaration(name: "didTapButton:", line: 1, column: 0)
        let nib = Nib(outlets: [], actions: [didTapButton])
        let map = ["A": Class(outlets: [], actions: [didTapButton], inherited: []),
                   "B": Class(outlets: [], actions: [], inherited: ["A"]),
                   "C": Class(outlets: [], actions: [], inherited: ["B"])]
        let configuration = AnalyzerConfiguration(classNameToNibMap: ["C": nib],
                                                  classNameToClassMap: map)
        XCTAssertEqual(issues(for: configuration), [])
    }

    func testUsesUIKitClasses() {
        let delegate = Declaration(name: "delegate:", line: 1, column: 0)
        let nib = Nib(outlets: [delegate], actions: [])
        let klass = Class(outlets: [], actions: [], inherited: ["UITextField"])
        let textField = Class(outlets: [delegate], actions: [], inherited: [])
        let configuration = AnalyzerConfiguration(classNameToNibMap: ["A": nib],
                                                  classNameToClassMap: ["A": klass],
                                                  uiKitClassNameToClassMap: ["UITextField": textField])
        XCTAssertEqual(issues(for: configuration), [])
    }

    private func issues(for configuration: AnalyzerConfiguration) -> [ConnectionIssue] {
        let analyzer = ConnectionAnalyzer()
        return (analyzer.issues(for: configuration) as? [ConnectionIssue]) ?? []
    }
}
