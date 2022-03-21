//
//  FSKit
//  DirectorySizeTest.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import XCTest
@testable import FSKit

class DirectorySizeTest: XCTestCase {
    
    private var directory: Directory!
    
    override func setUpWithError() throws {
        let testDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("dir", isDirectory: true)
        
        try FileManager.default.createDirectory(atPath: testDirURL.path, withIntermediateDirectories: true)
        directory = try Directory(at: testDirURL)
    }
    
    override func tearDownWithError() throws {
        try? FileManager.default.delete(directory)
        directory = nil
    }
    
    func testSize() throws {
        let f1URL = directory.url.appendingPathComponent("f1", isDirectory: false)
        let f1 = try File.create(at: f1URL)
        try f1.write(data: Data(repeating: 0, count: 100))
        
        let f2URL = directory.url.appendingPathComponent("f2", isDirectory: false)
        let f2 = try File.create(at: f2URL)
        try f2.write(data: Data(repeating: 1, count: 500))
        
        var fileSizeSum = f1.size! + f2.size!
        XCTAssertEqual(directory.size, fileSizeSum)
        
        let subDirURL = directory.url.appendingPathComponent("d1", isDirectory: true)
        let subDir = try Directory.create(at: subDirURL)
        
        let f3URL = subDir.url.appendingPathComponent("f3", isDirectory: false)
        let f3 = try File.create(at: f3URL)
        try f3.write(data: Data(repeating: 2, count: 1000))
        
        fileSizeSum += f3.size!
        XCTAssertEqual(directory.size, fileSizeSum)
    }
    
    func testAllocatedSize() throws {
        let f1 = try File.create(at: directory.url.appendingPathComponent("f1"))
        try f1.write(data: Data(repeating: 1, count: 1000))
        
        let f2 = try File.create(at: directory.url.appendingPathComponent("f2"))
        try f2.write(data: Data(repeating: 2, count: 2000))
        
        var fileSizeSum = f1.allocatedSize! + f2.allocatedSize!
        XCTAssertEqual(directory.allocatedSize, fileSizeSum)
        
        let subDir = try Directory.create(at: directory.url.appendingPathComponent("d1"))
        
        let f3 = try File.create(at: subDir.url.appendingPathComponent("f3"))
        try f3.write(data: Data(repeating: 3, count: 300))
        
        fileSizeSum += f3.allocatedSize!
        XCTAssertEqual(directory.allocatedSize, fileSizeSum)
    }
}
