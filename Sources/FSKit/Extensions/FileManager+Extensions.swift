//
//  FSKit
//  FileManager+Extensions.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import Foundation

public extension FileManager {
    
    // MARK: - Deleting Items
    
    func delete(_ item: FileSystemItem) throws {// item should be invalidated in some way.
        let itemPath = item.url.path
        do {
            try removeItem(atPath: itemPath)
        } catch {
            throw FSError.deleteFailed(path: itemPath, error: error)
        }
    }
}
