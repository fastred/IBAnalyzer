//
//  ConnectionAnalyzer.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 14/01/2017.
//  Copyright © 2017 Arkadiusz Holko. All rights reserved.
//

import Foundation

enum ConnectionIssue: Issue {
    case MissingOutlet(className: String, outlet: String)
    case MissingAction(className: String, action: String)
    case UnnecessaryOutlet(className: String, outlet: String)
    case UnnecessaryAction(className: String, action: String)

    var description: String {
        switch self {
        case let .MissingOutlet(className: className, outlet: outlet):
            return "\(className) doesn't implement a required @IBOutlet named: \(outlet)"
        case let .MissingAction(className: className, action: action):
            return "\(className) doesn't implement a required @IBAction named: \(action)"
        case let .UnnecessaryOutlet(className: className, outlet: outlet):
            return "\(className) contains unused @IBOutlet named: \(outlet)"
        case let .UnnecessaryAction(className: className, action: action):
            return "\(className) contains unused @IBAction named: \(action)"
        }
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
                    result.append(.MissingOutlet(className: className, outlet: outlet))
                }
            }

            for action in nib.actions {
                let matchAction: (Class) -> Bool = { $0.actions.contains(action) }

                if !classOrInheritedTypeOf(className: className, configuration: configuration, matches: matchAction) {
                    result.append(.MissingAction(className: className, action: action))
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
                    result.append(ConnectionIssue.UnnecessaryOutlet(className: className, outlet: outlet))
                }
            }

            for action in klass.actions {
                if !nib.actions.contains(action) {
                    result.append(ConnectionIssue.UnnecessaryAction(className: className, action: action))
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
