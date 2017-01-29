//
//  DirectoryContentsEnumerator.swift
//  IBAnalyzer
//
//  Created by Arkadiusz Holko on 24-12-16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation

protocol DirectoryContentsEnumeratorType {
    func files(at url: URL, fileManager: FileManager) throws -> [URL]
}

struct DirectoryContentsEnumerator: DirectoryContentsEnumeratorType {

    func files(at url: URL, fileManager: FileManager = FileManager.default) throws -> [URL] {
        guard let enumerator = fileManager.enumerator(at: url,
                                                      includingPropertiesForKeys: [],
                                                      options: [],
                                                      errorHandler: nil) else {
            return []
        }

        var fileURLs: [URL] = []

        for case let fileURL as URL in enumerator {
            let resourceValues = try fileURL.resolvingSymlinksInPath()
                .resourceValues(forKeys: [.pathKey, .isDirectoryKey])
            if let isDirectory = resourceValues.isDirectory,
                !isDirectory,
                let path = resourceValues.path {

                fileURLs.append(URL(fileURLWithPath: path))
            }
        }

        return fileURLs
    }
}
