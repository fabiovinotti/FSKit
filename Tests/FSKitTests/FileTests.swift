//
//  FSKit
//  FileTests.swift
//
//  Copyright © 2022 Fabio Vinotti. All rights reserved.
//  Licensed under MIT License.
//

import XCTest
@testable import FSKit

class FileTests: XCTestCase {
    
    private var testFile: File!

    override func setUpWithError() throws {
        let fm = FileManager.default
        let testFileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("sample.txt", isDirectory: false)
        
        XCTAssert(
            fm.createFile(atPath: testFileURL.path, contents: nil),
            "Failed to create a file for testing."
        )
        
        testFile = try File(at: testFileURL)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: testFile.url)
        testFile = nil
    }
    
    func testNameWithoutExtension() {
        // File with path extension
        var nameWithoutExtension = testFile.url.deletingPathExtension().lastPathComponent
        XCTAssertEqual(testFile.nameWithoutExtension, nameWithoutExtension)
        
        // File without path extension
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("fileWithNoPathExtension")
        
        let file: File
        do {
            file = try File.create(at: fileURL)
        } catch let e as FSError {
            return XCTFail(e.localizedDescription)
        } catch {
            return XCTFail(error.localizedDescription)
        }
        
        nameWithoutExtension = file.url.lastPathComponent
        XCTAssertEqual(file.nameWithoutExtension, nameWithoutExtension)
    }
    
    func testPathExtension() {
        XCTAssertEqual(testFile.pathExtension, testFile.url.pathExtension)
    }
    
    func testSize() throws {
        try testFile.write(data: Data(repeating: 0, count: 1000))
        
        let attributes = try FileManager.default.attributesOfItem(atPath: testFile.url.path)
        let fileSize = (attributes as NSDictionary).fileSize()
        XCTAssertEqual(testFile.size, Int(fileSize))
    }
    
    func testCopy() {
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("copied-sample.txt", isDirectory: false)
        
        defer { try? FileManager.default.removeItem(at: destinationURL) }
        
        do {
            try testFile.copy(to: destinationURL)
        } catch let e as FSError {
            return XCTFail(e.localizedDescription)
        } catch {
            return XCTFail("Failed to copy file: \(error.localizedDescription)")
        }
        
        let fm = FileManager.default
        
        XCTAssert(
            fm.fileExists(atPath: destinationURL.path),
            "The file has not been created."
        )
        
        XCTAssert(
            fm.contentsEqual(atPath: testFile.url.path, andPath: destinationURL.path),
            "Duplicated is different from the original."
        )
    }
    
    func testMove() {
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("copied-sample.txt", isDirectory: false)
        
        defer { try? FileManager.default.removeItem(at: destinationURL) }
        
        let urlBeforeMove = testFile.url
        
        do {
            try testFile.move(to: destinationURL)
        } catch let e as FSError {
            return XCTFail(e.localizedDescription)
        } catch {
            return XCTFail("Failed to move file: \(error.localizedDescription)")
        }
        
        XCTAssert(
            FileManager.default.fileExists(atPath: destinationURL.path),
            "File does not exists at destination URL."
        )
        
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: urlBeforeMove.path),
            "A file still exists at the original location."
        )
        
        XCTAssertEqual(
            testFile.url, destinationURL,
            "File's URL didn't point to the new location."
        )
    }
}
