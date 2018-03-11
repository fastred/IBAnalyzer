//
//  NibParser.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 24-12-16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation

protocol NibParserType {
    func mappingForFile(at url: URL) throws -> [String: Nib]
}

class NibParser: NibParserType {
    func mappingForFile(at url: URL) throws -> [String: Nib] {
        let parser = XMLParser(data: try Data(contentsOf: url))

        let delegate = ParserDelegate()
        delegate.url = url
        parser.delegate = delegate
        parser.parse()

        return delegate.classNameToNibMap
    }
}

// Thanks to SwiftGen for the inspiration :)

private class ParserDelegate: NSObject, XMLParserDelegate {

    private struct Element {
        let tag: String
        let customClassName: String?
    }

    var url: URL!
    var inObjects = false
    var inConnections = false
    private var stack: [Element] = []

    var classNameToNibMap: [String: Nib] = [:]
    var idToCustomClassMap: [String: String] = [:]

    @objc func parser(_ parser: XMLParser, didStartElement elementName: String,
                      namespaceURI: String?, qualifiedName qName: String?,
                      attributes attributeDict: [String: String]) {

        switch elementName {
        case "objects":
            inObjects = true
            stack = []
        case "connections":
            inConnections = true
        case "outlet" where inConnections, "outletCollection" where inConnections:
            guard let property = attributeDict["property"],
                let customClassName = stack.last?.customClassName else {
                    break
            }

            let outlet = Declaration(name: property, line: parser.lineNumber, column: parser.columnNumber, url: url)
            classNameToNibMap[customClassName]?.outlets.append(outlet)
        case "action" where inConnections:
            guard let selector = attributeDict["selector"],
                let destination = attributeDict["destination"],
                let customClassName = idToCustomClassMap[destination] else {
                    break
            }
            let action = Declaration(name: selector, line: parser.lineNumber, column: parser.columnNumber, url: url)
            classNameToNibMap[customClassName]?.actions.append(action)
        case let tag where (inObjects && tag != "viewControllerPlaceholder"):
            let customClass = attributeDict["customClass"]
            let id = attributeDict["id"]
            stack.append(Element(tag: tag, customClassName: customClass))

            if let customClass = customClass, let id = id {
                idToCustomClassMap[id] = customClass
                classNameToNibMap[customClass] = Nib(outlets: [], actions: [])
            }
        default:
            break
        }
    }

    @objc func parser(_ parser: XMLParser, didEndElement elementName: String,
                      namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "objects":
            inObjects = false
            assert(stack.count == 0)
        case "connections":
            inConnections = false
        case "outlet", "outletCollection", "action":
            break
        case let tag where (inObjects && tag != "viewControllerPlaceholder"):
            stack.removeLast()
        default:
            break
        }
    }
}
