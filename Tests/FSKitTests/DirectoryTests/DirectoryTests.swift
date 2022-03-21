//
//  FSKit
//  DirectoryTests.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import XCTest
@testable import FSKit

class DirectoryTests: XCTestCase {
    
    private var directory: Directory!
    
    override func setUpWithError() throws {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("dir", isDirectory: true)
        
        try FileManager.default.createDirectory(atPath: dirURL.path, withIntermediateDirectories: true)
        directory = try Directory(at: dirURL)
    }
    
    override func tearDownWithError() throws {
        try? FileManager.default.delete(directory)
        directory = nil
    }
    
    func testCreate() {
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("new-dir", isDirectory: true)
        
        do {
            try Directory.create(at: destinationURL)
        } catch let e as FSError {
            return XCTFail(e.localizedDescription)
        } catch {
            return XCTFail("Directory creation failed: \(error.localizedDescription)")
        }
        
        defer { try? FileManager.default.removeItem(at: destinationURL) }
        
        XCTAssert(
            FileManager.default.fileExists(atPath: destinationURL.path),
            "Directory does not exists."
        )
        
        XCTAssert(
            destinationURL.isDirectory,
            "File System Item is not a directory."
        )
    }
    
    func testMove() {
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("new-dir", isDirectory: true)
        
        defer { try? FileManager.default.removeItem(at: destinationURL) }
        
        let urlBeforeMove = directory.url
        
        do {
            try directory.move(to: destinationURL)
        } catch let e as FSError {
            return XCTFail(e.localizedDescription)
        } catch {
            return XCTFail("Failed to move file: \(error.localizedDescription)")
        }
        
        XCTAssert(
            FileManager.default.fileExists(atPath: destinationURL.path),
            "Directory does not exists at destination URL."
        )
        
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: urlBeforeMove.path),
            "A directory still exists at the original location."
        )
        
        XCTAssertEqual(
            directory.url, destinationURL,
            "Directory's URL didn't point to the new location."
        )
    }
    
    func testDeleteItemNamed() {
        let fileName = "new-file"
        let fileURL = directory.url.appendingPathComponent(fileName, isDirectory: false)
        
        XCTAssertFalse(directory.containsItem(named: fileName))
        
        do {
            try File.create(at: fileURL)
        } catch let e as FSError {
            return XCTFail(e.localizedDescription)
        } catch {
            return XCTFail(error.localizedDescription)
        }
        
        XCTAssert(directory.containsItem(named: fileName))
        
        do {
            try directory.deleteItem(named: fileName)
        } catch let e as FSError {
            return XCTFail(e.localizedDescription)
        } catch {
            return XCTFail(error.localizedDescription)
        }
        
        XCTAssertFalse(directory.containsItem(named: fileName))
    }
}
