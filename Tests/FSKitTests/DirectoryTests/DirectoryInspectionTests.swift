//
//  FSKit
//  DirectoryInspectionTests.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import XCTest
@testable import FSKit

class DirectoryInspectionTests: XCTestCase {
    
    private var directory: Directory!
    
    /// File located in the directory.
    private var file: File!
    
    override func setUpWithError() throws {
        let testDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("dir", isDirectory: true)
        
        try FileManager.default.createDirectory(atPath: testDirURL.path, withIntermediateDirectories: true)
        directory = try Directory(at: testDirURL)
        
        let fileURL = directory.url.appendingPathComponent("real-file")
        file = try File.create(at: fileURL)
    }

    override func tearDownWithError() throws {
        try FileManager.default.delete(directory)
        directory = nil
        file = nil
    }

    func testContainsItem() throws {
        XCTAssert(directory.containsItem(file))
    }
    
    func testContainsItemNamed() {
        XCTAssertFalse(directory.containsItem(named: "inexistent"))
        XCTAssert(directory.containsItem(named: file.name))
    }
}
