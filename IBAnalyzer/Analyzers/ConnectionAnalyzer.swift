//
//  ConnectionAnalyzer.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 14/01/2017.
//  Copyright © 2017 Arkadiusz Holko. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct Declaration {
    var name: String
    var line: Int
    var column: Int
    var url: URL?
    var isOptional: Bool

    init(name: String, line: Int, column: Int, url: URL? = nil, isOptional: Bool = false) {
        self.name = name
        self.line = line
        self.column = column
        self.url = url
        self.isOptional = isOptional
    }

    init(name: String, file: File, offset: Int64, isOptional: Bool = false) {
        let fileOffset = type(of: self).getLineColumnNumber(of: file, offset: Int(offset))
        var url: URL?
        if let path = file.path {
            url = URL(fileURLWithPath: path)
        }
        self.init(name: name, line: fileOffset.line, column: fileOffset.column, url: url, isOptional: isOptional)
    }

    var description: String {
        return filePath+":\(line):\(column)"
    }

    var filePath: String {
        if let path = url?.absoluteString {
            return path.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        }
        return name
    }

    func fileName(className: String) -> String {
        if let filename = url?.lastPathComponent {
            return filename
        }
        return className
    }

    private static func getLineColumnNumber(of file: File, offset: Int) -> (line: Int, column: Int) {
        let range = file.contents.startIndex..<file.contents.index(file.contents.startIndex, offsetBy: offset)
        let subString = file.contents.substring(with: range)
        let lines = subString.components(separatedBy: "\n")

        if let column = lines.last?.count {
            return (line: lines.count, column: column)
        }
        return (line: lines.count, column: 0)
    }
}

extension Declaration: Equatable {
    public static func == (lhs: Declaration, rhs: Declaration) -> Bool {
        return lhs.name == rhs.name
    }
}

enum ConnectionIssue: Issue {
    case missingOutlet(className: String, outlet: Declaration)
    case missingAction(className: String, action: Declaration)
    case unnecessaryOutlet(className: String, outlet: Declaration)
    case unnecessaryAction(className: String, action: Declaration)

    var description: String {
        switch self {
        case let .missingOutlet(className: className, outlet: outlet):
            return "\(outlet.description): warning: IBOutlet missing: \(outlet.name) is not implemented in \(outlet.fileName(className: className))"
        case let .missingAction(className: className, action: action):
            return "\(action.description): warning: IBAction missing: \(action.name) is not implemented in \(action.fileName(className: className))"
        case let .unnecessaryOutlet(className: className, outlet: outlet):
            if Configuration.shared.isEnabled(.ignoreOptionalProperty) && outlet.isOptional {
                return ""
            }
            let suggestion = outlet.isOptional ?
                ", remove warning by adding '\(Rule.ignoreOptionalProperty.rawValue)' argument" :
                ", consider set '\(outlet.name)' Optional"
            return "\(outlet.description): warning: IBOutlet unused: \(outlet.name) not linked in \(outlet.fileName(className: className))"+suggestion
        case let .unnecessaryAction(className: className, action: action):
            return "\(action.description): warning: IBAction unused: \(action.name) not linked in \(action.fileName(className: className))"
        }
    }

    var isSeriousViolation: Bool {
        switch self {
        case .missingOutlet, .missingAction:
            return true
        default:
            return false
        }
    }
}

enum Rule: String {
    case ignoreOptionalProperty //track optional properties
}

class Configuration {

    static let shared = Configuration()

    var configuration: [Rule: Bool] =
        [.ignoreOptionalProperty: false]

    private init() { }

    func setup(with arguments: [String]) {
        for argument in arguments {
            if let rule = Rule(rawValue: argument) {
                self.configuration[rule] = true
            }
        }
    }

    func isEnabled(_ rule: Rule) -> Bool {
        return configuration[rule] ?? false
    }
}

struct ConnectionAnalyzer: Analyzer {

    func issues(for configuration: AnalyzerConfiguration) -> [Issue] {
        var result: [Issue] = missingElements(for: configuration)
        result.append(contentsOf: unnecessaryElements(for: configuration))
        return result
    }

    // MARK: - Private

    private func missingElements(for configuration: AnalyzerConfiguration) -> [Issue] {
        var result: [ConnectionIssue] = []

        for (className, nib) in configuration.classNameToNibMap {
            guard nib.actions.count > 0 || nib.outlets.count > 0 else { continue }

            for outlet in nib.outlets {
                let matchOutlet: (Class) -> Bool = { $0.outlets.contains(outlet) }

                if !classOrInheritedTypeOf(className: className, configuration: configuration, matches: matchOutlet) {
                    result.append(.missingOutlet(className: className, outlet: outlet))
                }
            }

            for action in nib.actions {
                let matchAction: (Class) -> Bool = { $0.actions.contains(action) }

                if !classOrInheritedTypeOf(className: className, configuration: configuration, matches: matchAction) {
                    result.append(.missingAction(className: className, action: action))
                }
            }
        }

        return result
    }

    private func unnecessaryElements(for configuration: AnalyzerConfiguration) -> [Issue] {
        var result: [Issue] = []

        for (className, klass) in configuration.classNameToClassMap {
            guard klass.actions.count > 0 || klass.outlets.count > 0 else {
                continue
            }

            guard let nib = configuration.classNameToNibMap[className] else {
                // This can happen when for example an outlet/action is in a superclass
                // that doesn't have its own nib.
                continue
            }

            for outlet in klass.outlets {
                if !nib.outlets.contains(outlet) {
                    result.append(ConnectionIssue.unnecessaryOutlet(className: className, outlet: outlet))
                }
            }

            for action in klass.actions {
                if !nib.actions.contains(action) {
                    result.append(ConnectionIssue.unnecessaryAction(className: className, action: action))
                }
            }
        }

        return result
    }

    private func classOrInheritedTypeOf(className: String,
                                        configuration: AnalyzerConfiguration,
                                        matches match: (Class) -> Bool) -> Bool {
        guard let klass = configuration.classNameToClassMap[className] else {
            // Shouldn't really happen.
            return false
        }

        guard !match(klass) else {
            return true
        }

        var inheritedTypes = klass.inherited

        while inheritedTypes.count > 0 {
            // Removes first because it's most likely to be a class.
            let typeName = inheritedTypes.removeFirst()

            if let uiKitClass = configuration.uiKitClassNameToClassMap[typeName] {
                // It's possible that we're working with an outlet included in one of UIKit classes.
                if match(uiKitClass) {
                    return true
                }
            } else if let klass = configuration.classNameToClassMap[typeName] {
                if match(klass) {
                    return true
                } else {
                    inheritedTypes.append(contentsOf: klass.inherited)
                }
            }
        }

        return false
    }
}
