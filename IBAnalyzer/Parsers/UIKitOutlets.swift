//
//  UIKitOutlets.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 17/01/2017.
//  Copyright © 2017 Arkadiusz Holko. All rights reserved.
//

import Foundation

/// Special outlets declared in UIKit classes.
private let uiKitOutlets: [String: [String]] = [
    "UITextField": ["delegate"],
    "UITableView": ["delegate", "dataSource"],
    "UITableViewCell": ["accessoryView", "backgroundView", "editingAccessoryView", "selectedBackgroundView"],
    "UICollectionView": ["delegate", "dataSource", "prefetchDataSource"],
    "UICollectionViewCell": ["backgroundView", "selectedBackgroundView"],
    "UITextView": ["delegate"],
    "UIScrollView": ["delegate"],
    "UIPickerView": ["delegate", "dataSource"],
    "MKMapView": ["delegate"],
    "GLKView": ["delegate"],
    "SCNView": ["delegate"],
    "UIWebView": ["delegate"],
    "UITapGestureRecognizer": ["delegate"],
    "UIPinchGestureRecognizer": ["delegate"],
    "UIRotationGestureRecognizer": ["delegate"],
    "UISwipeGestureRecognizer": ["delegate"],
    "UIPanGestureRecognizer": ["delegate"],
    "UIScreenEdgePanGestureRecognizer": ["delegate"],
    "UILongPressGestureRecognizer": ["delegate"],
    "UIGestureRecognizer": ["delegate"],
    "UINavigationBar": ["delegate"],
    "UINavigationItem": ["backBarButtonItem", "leftBarButtonItem", "rightBarButtonItem", "titleView"],
    "UIToolbar": ["delegate"],
    "UITabBar": ["delegate"],
    "UISearchBar": ["delegate"]
]

func uiKitClassNameToClass() -> [String: Class] {
    var dict: [String: Class] = [:]
    for (name, outlets) in uiKitOutlets {
        dict[name] = Class(outlets: outlets, actions: [], inherited: [])
    }

    return dict
}
