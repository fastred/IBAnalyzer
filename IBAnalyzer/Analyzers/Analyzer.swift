//
//  Analyzer.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 29/01/2017.
//  Copyright © 2017 Arkadiusz Holko. All rights reserved.
//

import Foundation

struct AnalyzerConfiguration {
    let classNameToNibMap: [String: Nib]
    let classNameToClassMap: [String: Class]
    let uiKitClassNameToClassMap: [String: Class]

    init(classNameToNibMap: [String: Nib],
         classNameToClassMap: [String: Class],
         uiKitClassNameToClassMap: [String: Class] = uiKitClassNameToClass()) {
        self.classNameToNibMap = classNameToNibMap
        self.classNameToClassMap = classNameToClassMap
        self.uiKitClassNameToClassMap = uiKitClassNameToClassMap
    }
}

protocol Issue: CustomStringConvertible {
}

protocol Analyzer {
    func issues(for configuration: AnalyzerConfiguration) -> [Issue]
}
