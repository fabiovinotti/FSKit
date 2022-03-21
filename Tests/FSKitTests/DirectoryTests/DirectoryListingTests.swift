//
//  FSKit
//  DirectoryListingTests.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import XCTest
@testable import FSKit

class DirectoryListingTests: XCTestCase {
    
    private var directory: Directory!

    override func setUpWithError() throws {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("directory", isDirectory: true)
        
        try FileManager.default.createDirectory(atPath: dirURL.path, withIntermediateDirectories: true)
        directory = try Directory(at: dirURL)
    }

    override func tearDownWithError() throws {
        try FileManager.default.delete(directory)
        directory = nil
    }
    
    func testListContents() throws {
        // Directory should be empty initially.
        XCTAssert(try directory.listContents().isEmpty)
        
        let addedContentsURLs = try populateWithContents()
            .sorted { $0.path < $1.path }
            .map { $0.url }

       let directoryContentsURLs = try directory.listContents()
            .sorted { $0.path < $1.path }
            .map { $0.url }
        
        XCTAssertEqual(addedContentsURLs, directoryContentsURLs)
    }
    
    func testListFiles() throws {
        // Directory should be empty initially.
        XCTAssert(try directory.listFiles().isEmpty)
        
        let addedFiles = try populateWithContents()
            .compactMap { try? File(at: $0.path) }
            .sorted { $0.path < $1.path }

       let directoryFiles = try directory.listFiles()
            .sorted { $0.path < $1.path }
        
        XCTAssertEqual(addedFiles, directoryFiles)
    }
    
    func testListDirectories() throws {
        // Directory should be empty initially.
        XCTAssert(try directory.listDirectories().isEmpty)
        
        let addedDirs = try populateWithContents()
            .compactMap { try? Directory(at: $0.path) }
            .sorted { $0.path < $1.path }

       let subdirectories = try directory.listDirectories()
            .sorted { $0.path < $1.path }
        
        XCTAssertEqual(addedDirs, subdirectories)
    }
    
    private func populateWithContents() throws -> [FileSystemItem] {
        let f1URL = directory.url.appendingPathComponent("f1", isDirectory: false)
        let f1 = try File.create(at: f1URL)
        try f1.write(data: Data(repeating: 0, count: 100))
        
        let f2URL = directory.url.appendingPathComponent("f2", isDirectory: false)
        let f2 = try File.create(at: f2URL)
        try f2.write(data: Data(repeating: 1, count: 500))
        
        let dir1URL = directory.url.appendingPathComponent("dir1", isDirectory: true)
        let dir1 = try File.create(at: dir1URL)
        
        let dir2URL = directory.url.appendingPathComponent("dir2", isDirectory: true)
        let dir2 = try Directory.create(at: dir2URL)
        
        return [f1, f2, dir1, dir2]
    }
}
