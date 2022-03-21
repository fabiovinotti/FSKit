//
//  FSKit
//  FileSystemItem.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import Foundation
import UniformTypeIdentifiers

/// A type that represents a file system resource.
public protocol FileSystemItem {
    
    /// The location of the item in the file system.
    var url: URL { get }
    
    /// Total size of the item in bytes.
    ///
    /// This value includes the space used by metadata.
    ///
    /// - returns: A value indicating the item size or nil if an error occurred.
    var size: Int? { get }
    
    /// Total size allocated on disk for the item in bytes.
    ///
    /// This value reflects the space of the blocks used to store the item on the volume.
    /// It includes the space used by metadata and is affected by the use of file system compression.
    /// When the item is compressed by the file system, the allocated size may be smaller than the file size.
    ///
    /// - returns: A value indicating the disk space used to store the item or nil if an error occurred.
    var allocatedSize: Int? { get }
    
    init(at filePath: String) throws
    init(at fileURL: URL) throws
    
    /// Synchronously moves the item to the specified URL.
    func move(to destinationURL: URL) throws
}

public extension FileSystemItem {
    
    /// The name of the item.
    ///
    /// It includes the file path extension, if any.
    var name: String {
        url.lastPathComponent
    }
    
    var path: String {
        url.path
    }
    
    var parentDirectoryURL: URL {
        let resourceValues = try? url.resourceValues(forKeys: [.parentDirectoryURLKey])
        return resourceValues?.parentDirectory ?? url.deletingLastPathComponent()
    }
    
    var creationDate: Date? {
        let resourceValues = try? url.resourceValues(forKeys: [.creationDateKey])
        return resourceValues?.creationDate
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    var contentType: UTType? {
        let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey])
        return resourceValues?.contentType
    }
    
    // MARK: - Copying Items
    
    func copy(to destinationURL: URL) throws {
        do {
            try FileManager.default.copyItem(at: url, to: destinationURL)
        } catch {
            throw FSError.copyFailed(toPath: destinationURL.path, error: error)
        }
    }
    
    func copy(to destinationPath: String) throws {
        do {
            try FileManager.default.copyItem(atPath: url.path, toPath: destinationPath)
        } catch {
            throw FSError.copyFailed(toPath: destinationPath, error: error)
        }
    }
    
    // MARK: - Comparing Items
    
    func contentsEqual(to file: FileSystemItem) -> Bool {
        FileManager.default.contentsEqual(atPath: url.path, andPath: file.url.path)
    }
    
    func contentsEqual(to fileURL: URL) -> Bool {
        FileManager.default.contentsEqual(atPath: url.path, andPath: fileURL.path)
    }
    
    func contentsEqual(to filePath: String) -> Bool {
        FileManager.default.contentsEqual(atPath: url.path, andPath: filePath)
    }
}
