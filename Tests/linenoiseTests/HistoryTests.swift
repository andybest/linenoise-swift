/*
 Copyright (c) 2017, Andy Best <andybest.net at gmail dot com>
 Copyright (c) 2010-2014, Salvatore Sanfilippo <antirez at gmail dot com>
 Copyright (c) 2010-2013, Pieter Noordhuis <pcnoordhuis at gmail dot com>
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import XCTest
import Nimble
@testable import LineNoise

class HistoryTests: XCTestCase {
    
    // MARK: - Adding Items
    func testHistoryAddItem() {
        let h = History()
        h.add("Test")
        
        expect(h.historyItems).to(equal(["Test"]))
    }
    
    func testHistoryDoesNotAddDuplicatedLines() {
        let h = History()
        
        h.add("Test")
        h.add("Test")
        
        expect(h.historyItems).to(haveCount(1))
        
        // Test adding a new item in-between doesn't de-dupe the newest line
        h.add("Test 2")
        h.add("Test")
        
        expect(h.historyItems).to(haveCount(3))
    }
    
    func testHistoryHonorsMaxLength() {
        let h = History()
        h.maxLength = 2
        
        h.add("Test 1")
        h.add("Test 2")
        h.add("Test 3")
        
        expect(h.historyItems).to(haveCount(2))
        expect(h.historyItems).to(equal(["Test 2", "Test 3"]))
    }
    
    func testHistoryRemovesEntriesWhenMaxLengthIsSet() {
        let h = History()
        
        h.add("Test 1")
        h.add("Test 2")
        h.add("Test 3")
        
        expect(h.historyItems).to(haveCount(3))
        
        h.maxLength = 2
        
        expect(h.historyItems).to(haveCount(2))
        expect(h.historyItems).to(equal(["Test 2", "Test 3"]))
    }
    
    // MARK: Navigation
    
    func testHistoryNavigationReturnsNilWhenHistoryEmpty() {
        let h = History()
        
        expect(h.navigateHistory(direction: .next)).to(beNil())
        expect(h.navigateHistory(direction: .previous)).to(beNil())
    }
    
    func testHistoryNavigationReturnsSingleItemWhenHistoryHasOneItem() {
        let h = History()
        h.add("Test")
        
        expect(h.navigateHistory(direction: .next)).to(beNil())
        
        guard let previousItem = h.navigateHistory(direction: .previous) else {
            XCTFail("Expected previous item to not be nil")
            return
        }
        
        expect(previousItem).to(equal("Test"))
    }
    
    func testHistoryStopsAtBeginning() {
        let h = History()
        h.add("1")
        h.add("2")
        h.add("3")
        
        expect(h.navigateHistory(direction: .previous)).to(equal("3"))
        expect(h.navigateHistory(direction: .previous)).to(equal("2"))
        expect(h.navigateHistory(direction: .previous)).to(equal("1"))
        expect(h.navigateHistory(direction: .previous)).to(beNil())
    }
    
    func testHistoryNavigationStopsAtEnd() {
        let h = History()
        h.add("1")
        h.add("2")
        h.add("3")
        
        expect(h.navigateHistory(direction: .next)).to(beNil())
    }
    
    // MARK: - Saving and Loading
    
    func testHistorySavesToFile() {
        let h = History()
        
        h.add("Test 1")
        h.add("Test 2")
        h.add("Test 3")
        
        let tempFile = "/tmp/ln_history_save_test.txt"
        
        expect(try h.save(toFile: tempFile)).notTo(throwError())
        
        let fileContents: String
        
        do {
            fileContents = try String(contentsOfFile: tempFile)
        } catch {
            XCTFail("Loading file should not throw exception")
            return
        }
        
        // Reading the file should yield the same lines as input
        let items = fileContents.split(separator: "\n")
        
        expect(items).to(equal(["Test 1", "Test 2", "Test 3"]))
    }
    
    func testHistoryLoadsFromFile() {
        let h = History()
        
        let tempFile = "/tmp/ln_history_load_test.txt"
        
        do {
            try "Test 1\nTest 2\nTest 3".write(toFile: tempFile, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Writing file should not throw exception")
        }
        
        expect(try h.load(fromFile: tempFile)).toNot(throwError())
        
        expect(h.historyItems).to(haveCount(3))
        expect(h.historyItems).to(equal(["Test 1", "Test 2", "Test 3"]))
    }
    
    func testHistoryLoadingRespectsMaxLength() {
        let h = History()
        h.maxLength = 2
        
        let tempFile = "/tmp/ln_history_load_test.txt"
        
        do {
            try "Test 1\nTest 2\nTest 3".write(toFile: tempFile, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Writing file should not throw exception")
        }
        
        expect(try h.load(fromFile: tempFile)).toNot(throwError())
        
        expect(h.historyItems).to(haveCount(2))
        expect(h.historyItems).to(equal(["Test 2", "Test 3"]))
    }
    
}
