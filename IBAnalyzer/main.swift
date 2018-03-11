//
//  main.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 24-12-16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation
import AppKit

let isInUnitTests = NSClassFromString("XCTest") != nil

if !isInUnitTests {
    do {
        let args = ProcessInfo.processInfo.arguments
        guard args.count > 1 else {
            print("Please provide a project path as a first argument.")
            exit(1)
        }

        let currentDirectoryPath = FileManager.default.currentDirectoryPath
        let url = URL(fileURLWithPath: args[1], relativeTo: URL(fileURLWithPath: currentDirectoryPath))

        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Path \(url.path) doesn't exist.")
            exit(1)
        }

        print("Analyzing files located at: \(url.path)")

        let runner = Runner(path: url.path)
        Configuration.shared.setup(with: args)
        let issues = try runner.issues(using: [ConnectionAnalyzer()])
        var hasSeriousViolation: Bool = false
        for issue in issues {
            if issue.isSeriousViolation {
                hasSeriousViolation = true
            }
            print(issue)
        }
        if hasSeriousViolation {
            exit(2)
        }
    } catch let error {
        print(error.localizedDescription)
        exit(1)
    }
} else {
    final class TestAppDelegate: NSObject, NSApplicationDelegate {
        let window = NSWindow()

        func applicationDidFinishLaunching(aNotification: NSNotification) {
            window.setFrame(CGRect(x: 0, y: 0, width: 0, height: 0), display: false)
            window.makeKeyAndOrderFront(self)
        }
    }

    // This is required for us to be able to run unit tests.
    autoreleasepool { () -> Void in
        let app = NSApplication.shared()
        let appDelegate = TestAppDelegate()
        app.delegate = appDelegate
        app.run()
    }
}
