//
//  Class.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 29/01/2017.
//  Copyright © 2017 Arkadiusz Holko. All rights reserved.
//

import Foundation

struct Class {
    var outlets: [Declaration]
    var actions: [Declaration]
    var inherited: [String]
}

extension Class: Equatable {
    public static func == (lhs: Class, rhs: Class) -> Bool {
        return lhs.outlets == rhs.outlets
            && lhs.actions == rhs.actions
            && lhs.inherited == rhs.inherited
    }
}
