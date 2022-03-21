//
//  FSKit
//  File.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import Foundation

/// A file system item that represents a regular file.
public class File: FileSystemItem {
    
    public private(set) var url: URL
    
    public var nameWithoutExtension: String {
        url.deletingPathExtension().lastPathComponent
    }
    
    public var pathExtension: String {
        url.pathExtension
    }
    
    public var size: Int? {
        let values = try? url.resourceValues(forKeys: [
            .totalFileSizeKey,
            .fileSizeKey
        ])
        
        return values?.totalFileSize ?? values?.fileSize
    }
    
    public var allocatedSize: Int? {
        let values = try? url.resourceValues(forKeys: [
            .totalFileAllocatedSizeKey,
            .fileAllocatedSizeKey
        ])
        
        return values?.totalFileAllocatedSize ?? values?.fileAllocatedSize
    }
    
    // MARK: - Creating
    
    /// Creates a new file at the provided URL.
    ///
    /// If a file already exists at the provided location, that file is returned.
    @discardableResult
    public static func create(at destinationURL: URL, contents: Data? = nil) throws -> File {
        try create(at: destinationURL.path, contents: contents)
    }
    
    /// Creates a new file at the provided path.
    ///
    /// If a file already exists at the provided location, that file is returned.
    @discardableResult
    public static func create(at destinationPath: String, contents: Data? = nil) throws -> File {
        let file: File
        
        if FileManager.default.createFile(atPath: destinationPath, contents: contents) {
            file = try File(at: destinationPath)
        } else {
            throw FSError.fileCreationFailed(path: destinationPath)
        }
        
        return file
    }
    
    // MARK: - Opening
    
    public required convenience init(at fileURL: URL) throws {
        try self.init(at: fileURL.path)
    }
    
    public required init(at filePath: String) throws {
        var isDir: ObjCBool = false
        
        guard FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir) else {
            throw FSError.itemDoesNotExist(path: filePath)
        }
        
        guard !isDir.boolValue else {
            throw FSError.incompatibleItemExistsAtLocation(path: filePath)
        }
        
        url = URL(fileURLWithPath: filePath)
    }
    
    // MARK: - Moving
    
    public func move(to destinationURL: URL) throws {
        try move(to: destinationURL.path)
    }
    
    public func move(to destinationPath: String) throws {
        do {
            try FileManager.default.moveItem(atPath: path, toPath: destinationPath)
            url = URL(fileURLWithPath: destinationPath)
        } catch {
            throw FSError.moveFailed(toPath: destinationPath, error: error)
        }
    }
    
    // MARK: - Reading / Writing
    
    public func read(options: Data.ReadingOptions = []) throws -> Data {
        do {
            return try Data(contentsOf: url, options: options)
        } catch {
            throw FSError.readDataFailed(path: path, error: error)
        }
    }
    
    /// Writes the specified data buffer to the file location.
    public func write(data: Data, options: Data.WritingOptions = []) throws {
        do {
            try data.write(to: url, options: options)
        } catch {
            throw FSError.writeDataFailed(path: path, error: error)
        }
    }
}

extension File: Equatable {
    public static func == (lhs: File, rhs: File) -> Bool {
        lhs.url == rhs.url
    }
}

extension File: CustomDebugStringConvertible {
    public var debugDescription: String {
        "File(name: \(name))"
    }
}
