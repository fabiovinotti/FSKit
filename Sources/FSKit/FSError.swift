//
//  FSKit
//  FSError.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import Foundation

/// An error reported by FSKit.
public enum FSError: Error {
    
    /// File creation failed for no known reason.
    case fileCreationFailed(path: String)
    
    case directoryCreationFailed(path: String, error: Error)
    case itemDoesNotExist(path: String)
    case copyFailed(toPath: String, error: Error)
    case moveFailed(toPath: String, error: Error)
    case deleteFailed(path: String, error: Error)
    case listContentsFailed(error: Error)
    
    case readDataFailed(path: String, error: Error)
    case writeDataFailed(path: String, error: Error)
    
    /// There is a file system item of a different type than the one you are trying to open.
    ///
    /// Occurs when trying to initialize a file with a directory location or a directory with
    /// a file location.
    case incompatibleItemExistsAtLocation(path: String)
    
    public var localizedDescription: String {
        switch self {
        case let .fileCreationFailed(path: p):
            return "File creation failed for no known reasona at path \(p)."
            
        case let .directoryCreationFailed(path: p, error: e):
            return "Failed to create directory at \(p): \(e.localizedDescription)"
            
        case let .itemDoesNotExist(path: p):
            return "File does not exist at \(p)"
            
        case let .copyFailed(toPath: p, error: e):
            return "Failed to copy the item to \(p): \(e.localizedDescription)"
            
        case let .moveFailed(toPath: p, error: e):
            return "Failed to move the item to \(p): \(e.localizedDescription)"
            
        case let .deleteFailed(path: p, error: e):
            return "Failed to delete the file at \(p): \(e.localizedDescription)"
            
        case let .listContentsFailed(error: e):
            return "Failed to retrieve directory contents: \(e.localizedDescription)"
            
        case let .readDataFailed(path: p, error: e):
            return "Failed to read data at \(p): \(e.localizedDescription)"
            
        case let .writeDataFailed(path: p, error: e):
            return "Failed to write data to \(p): \(e.localizedDescription)"
            
        case let .incompatibleItemExistsAtLocation(path: p):
            return "An incompatible file system item exists at \(p)."
        }
    }
}
