//
//  FSKit
//  FileSystemItemTests.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import XCTest
@testable import FSKit

// MARK: - File System Item Tests

class FileSystemItemTests: XCTestCase {
    
    private var testItem: DummyFileSystemItem!
    private let testItemURL = URL(fileURLWithPath: "/Users/fabio/sample.txt", isDirectory: false)
    
    override func setUp() {
        testItem = DummyFileSystemItem(at: testItemURL)
    }
    
    override func tearDown() {
        testItem = nil
    }
    
    func testName() {
        XCTAssertEqual(testItem.name, testItemURL.lastPathComponent)
    }
    
    func testPath() {
        XCTAssertEqual(testItem.path, testItemURL.path)
    }
    
    func testParentDirectoryURL() throws {
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let dir = try Directory.create(at: tempDirURL.appendingPathComponent("new-dir"))
        XCTAssertEqual(dir.parentDirectoryURL, tempDirURL)
        
        let file = try File.create(at: dir.url.appendingPathComponent("new-file"))
        XCTAssertEqual(file.parentDirectoryURL, dir.url)
    }
}

// MARK: - Dummy File System Item

/// A FileSystemItem-compliant object that does not override any default implementation.
fileprivate class DummyFileSystemItem: FileSystemItem {
    var url: URL
    var size: Int? = 0
    var allocatedSize: Int? = 0
    
    required init(at itemURL: URL) {
        url = itemURL
    }
    
    required init(at filePath: String) throws {
        url = URL(fileURLWithPath: filePath)
    }
    
    func move(to destinationURL: URL) throws {}
    func move(to destinationPath: String) throws {}
}
