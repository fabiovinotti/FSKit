//
//  FSKit
//  Directory.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import Foundation

/// A file system item that represents a directory.
public class Directory: FileSystemItem {
    
    public private(set) var url: URL
    
    // MARK: - Calculating Size
    
    public var size: Int? {
        let resourceKeys: [URLResourceKey] = [
            .totalFileSizeKey,
            .fileSizeKey
        ]
        
        return coordinateSizeCalculation(
            fetchingPropertiesForKeys: resourceKeys,
            filePropertyToSum: \.size
        )
    }
    
    public var allocatedSize: Int? {
        let resourceKeys: [URLResourceKey] = [
            .totalFileAllocatedSizeKey,
            .fileAllocatedSizeKey
        ]
        
        return coordinateSizeCalculation(
            fetchingPropertiesForKeys: resourceKeys,
            filePropertyToSum: \.allocatedSize
        )
    }
    
    private func coordinateSizeCalculation(fetchingPropertiesForKeys: [URLResourceKey],
                                           filePropertyToSum: KeyPath<File, Int?>) -> Int? {
        
        let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: fetchingPropertiesForKeys
        )
        
        guard let enumerator = enumerator else { return nil }
        
        var allocatedSize: Int = 0
        
        for case let itemURL as URL in enumerator {
            guard let file = try? File(at: itemURL) else { continue }
            allocatedSize += file[keyPath: filePropertyToSum] ?? 0
        }
        
        return allocatedSize
    }
    
    // MARK: - Creating
    
    /// Creates a new directory at the specified URL.
    ///
    /// If a directory already exists at the provided location, that directory is returned.
    @discardableResult
    public static func create(at destinationURL: URL) throws -> Directory {
        try create(at: destinationURL.path)
    }
    
    /// Creates a new directory at the specified path.
    ///
    /// If a directory already exists at the provided location, that directory is returned.
    @discardableResult
    public static func create(at destinationPath: String) throws -> Directory {
        do {
            try FileManager.default.createDirectory(
                atPath: destinationPath,
                withIntermediateDirectories: true)
        } catch {
            throw FSError.directoryCreationFailed(path: destinationPath, error: error)
        }
        
        return try Directory(at: destinationPath)
    }
    
    // MARK: - Opening
    
    public required convenience init(at directoryURL: URL) throws {
        try self.init(at: directoryURL.path)
    }
    
    public required init(at directoryPath: String) throws {
        var isDir: ObjCBool = false
        
        guard FileManager.default.fileExists(atPath: directoryPath, isDirectory: &isDir) else {
            throw FSError.itemDoesNotExist(path: directoryPath)
        }
        
        guard isDir.boolValue else {
            throw FSError.incompatibleItemExistsAtLocation(path: directoryPath)
        }
        
        url = URL(fileURLWithPath: directoryPath)
    }
    
    // MARK: - Moving
    
    /// Synchronously moves the item to the specified URL.
    ///
    /// This method moves the directory and all of its contents, including any hidden files.
    public func move(to destinationURL: URL) throws {
        try move(to: destinationURL.path)
    }
    
    /// Synchronously moves the item to the specified path.
    ///
    /// This method moves the directory and all of its contents, including any hidden files.
    public func move(to destinationPath: String) throws {
        do {
            try FileManager.default.moveItem(atPath: path, toPath: destinationPath)
            url = URL(fileURLWithPath: destinationPath)
        } catch {
            throw FSError.moveFailed(toPath: destinationPath, error: error)
        }
    }
    
    // MARK: - Listing Contents
    
    /// - returns: An array containing all the files system items in the directory.
    public func listContents() throws -> [FileSystemItem] {
        do {
            return try FileManager.default
                .contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey])
                .compactMap {
                    guard let resourceValues = try? $0.resourceValues(forKeys: [.isDirectoryKey]),
                          let isDirectory = resourceValues.isDirectory
                    else { return nil }
                    
                    return isDirectory ? try? Directory(at: $0) : try? File(at: $0)
                }
        } catch {
            throw FSError.listContentsFailed(error: error)
        }
    }
    
    /// - returns: An array containing all the files in the directory.
    public func listFiles() throws -> [File] {
        do {
            return try FileManager.default
                .contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey])
                .filter { $0.isRegularFile }
                .compactMap { try? File(at: $0) }
        } catch {
            throw FSError.listContentsFailed(error: error)
        }
    }
    
    /// - returns: An array containing all the directories in the directory.
    public func listDirectories() throws -> [Directory] {
        do {
            return try FileManager.default
                .contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey])
                .filter { $0.isDirectory }
                .compactMap { try? Directory(at: $0) }
        } catch {
            throw FSError.listContentsFailed(error: error)
        }
    }
    
    // MARK: - Inspecting Contents
    
    /// Whether the specified file system item is in this directory.
    public func containsItem(_ item: FileSystemItem) -> Bool {
        url == item.parentDirectoryURL
    }
    
    /// Whether a file or directory with the specified name exists in this directory.
    public func containsItem(named name: String) -> Bool {
        let filePath = url.appendingPathComponent(name).path
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    // MARK: - Deleting Contents
    
    public func deleteItem(named name: String) throws {
        let itemURL = url.appendingPathComponent(name)
        do {
            try FileManager.default.removeItem(at: itemURL)
        } catch {
            throw FSError.deleteFailed(path: itemURL.path, error: error)
        }
    }
    
    // MARK: - Creating Subdirectories
    
    public func createSubdirectory(named name: String) throws -> Directory {
        let subdirectoryURL = url.appendingPathComponent(name, isDirectory: true)
        return try Directory.create(at: subdirectoryURL)
    }
}

extension Directory: Equatable {
    public static func == (lhs: Directory, rhs: Directory) -> Bool {
        lhs.url == rhs.url
    }
}

extension Directory: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Directory(name: \(name))"
    }
}
