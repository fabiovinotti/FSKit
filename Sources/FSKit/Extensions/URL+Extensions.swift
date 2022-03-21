//
//  FSKit
//  URL+Extensions.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import Foundation

extension URL {
    
    /// Whether the resource is a regular file, as opposed to a directory or a symbolic link.
    var isRegularFile: Bool {
        let resourceValues = try? resourceValues(forKeys: [.isRegularFileKey])
        return resourceValues?.isRegularFile ?? false
    }
    
    /// Whether the resource is a directory.
    var isDirectory: Bool {
        let resourceValues = try? resourceValues(forKeys: [.isDirectoryKey])
        return resourceValues?.isDirectory ?? false
    }
}
