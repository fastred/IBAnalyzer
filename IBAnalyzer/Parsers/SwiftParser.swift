//
//  SwiftParser.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 26-12-16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation
import SourceKittenFramework

protocol SwiftParserType {
    func mappingForFile(at url: URL) throws -> [String: Class]
    func mappingForContents(_ contents: String) -> [String: Class]
}

enum SwiftParserError: Error {
    case incorrectPath(path: String)
}

class SwiftParser: SwiftParserType {
    func mappingForFile(at url: URL) throws -> [String: Class] {
        if let file = File(path: url.path) {
            return mapping(for: file)
        } else {
            throw SwiftParserError.incorrectPath(path: url.path)
        }
    }

    func mappingForContents(_ contents: String) -> [String: Class] {
        return mapping(for: File(contents: contents))
    }

    private func mapping(for file: File) -> [String: Class] {
        let fileStructure = Structure(file: file)
        let dictionary = fileStructure.dictionary

        var result: [String: Class] = [:]
        parseSubstructure(dictionary.substructure, result: &result)
        return result
    }

    private func parseSubstructure(_ substructure: [[String : SourceKitRepresentable]],
                                   result: inout [String: Class]) {
        for structure in substructure {
            var outlets: [String] = []
            var actions: [String] = []

            if let kind = structure["key.kind"] as? String,
                let name = structure["key.name"] as? String,
                kind == "source.lang.swift.decl.class" || kind == "source.lang.swift.decl.extension" {

                for insideStructure in structure.substructure {
                    if let attributes = insideStructure["key.attributes"] as? [[String: String]],
                        let name = insideStructure["key.name"] as? String {

                        let isOutlet = attributes.filter({ (dict) -> Bool in
                            return dict.values.contains("source.decl.attribute.iboutlet")
                        }).count > 0

                        if isOutlet {
                            outlets.append(name)
                        }

                        let isIBAction = attributes.filter({ (dict) -> Bool in
                            return dict.values.contains("source.decl.attribute.ibaction")
                        }).count > 0

                        if isIBAction, let selectorName = insideStructure["key.selector_name"] as? String {
                            actions.append(selectorName)
                        }
                    }
                }

                parseSubstructure(structure.substructure, result: &result)
                let inherited = extractedInheritedTypes(structure: structure)
                let existing = result[name]

                // appending needed becauase of extensions
                result[name] = Class(outlets: outlets + (existing?.outlets ?? []),
                                              actions: actions + (existing?.actions ?? []),
                                              inherited: inherited + (existing?.inherited ?? []))
            }
        }
    }

    private func extractedInheritedTypes(structure: [String : SourceKitRepresentable]) -> [String] {
        guard let inherited = structure["key.inheritedtypes"] as? [[String: String]] else {
            return []
        }

        let result = inherited.map { $0["key.name"] }.flatMap { $0 }
        return result
    }
}

private extension Dictionary where Key: ExpressibleByStringLiteral {
    var substructure: [[String: SourceKitRepresentable]] {
        let substructure = self["key.substructure"] as? [SourceKitRepresentable] ?? []
        return substructure.flatMap { $0 as? [String: SourceKitRepresentable] }
    }
}
