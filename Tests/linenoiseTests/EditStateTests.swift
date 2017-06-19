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

class EditStateTests: XCTestCase {
    
    func testInitEmptyBuffer() {
        let s = EditState(prompt: "$ ")
        expect(s.currentBuffer).to(equal(""))
        expect(s.location).to(equal(s.currentBuffer.startIndex))
        expect(s.prompt).to(equal("$ "))
    }
    
    func testInsertCharacter() {
        let s = EditState(prompt: "")
        s.insertCharacter("A"["A".startIndex])
        
        expect(s.buffer).to(equal("A"))
        expect(s.location).to(equal(s.currentBuffer.endIndex))
        expect(s.cursorPosition).to(equal(1))
    }
    
    func testBackspace() {
        let s = EditState(prompt: "")
        s.insertCharacter("A"["A".startIndex])
        
        expect(s.backspace()).to(beTrue())
        expect(s.currentBuffer).to(equal(""))
        expect(s.location).to(equal(s.currentBuffer.startIndex))
        
        // No more characters left, so backspace should return false
        expect(s.backspace()).to(beFalse())
    }
    
    func testMoveLeft() {
        let s = EditState(prompt: "")
        s.buffer = "Hello"
        s.location = s.currentBuffer.endIndex
        
        expect(s.moveLeft()).to(beTrue())
        expect(s.cursorPosition).to(equal(4))
        
        s.location = s.currentBuffer.startIndex
        expect(s.moveLeft()).to(beFalse())
    }
    
    func testMoveRight() {
        let s = EditState(prompt: "")
        s.buffer = "Hello"
        s.location = s.currentBuffer.startIndex
        
        expect(s.moveRight()).to(beTrue())
        expect(s.cursorPosition).to(equal(1))
        
        s.location = s.currentBuffer.endIndex
        expect(s.moveRight()).to(beFalse())
    }
    
    func testMoveHome() {
        let s = EditState(prompt: "")
        s.buffer = "Hello"
        s.location = s.currentBuffer.endIndex
        
        expect(s.moveHome()).to(beTrue())
        expect(s.cursorPosition).to(equal(0))
        
        expect(s.moveHome()).to(beFalse())
    }
    
    func testMoveEnd() {
        let s = EditState(prompt: "")
        s.buffer = "Hello"
        s.location = s.currentBuffer.startIndex
        
        expect(s.moveEnd()).to(beTrue())
        expect(s.cursorPosition).to(equal(5))
        
        expect(s.moveEnd()).to(beFalse())
    }
    
    func testRemovePreviousWord() {
        let s = EditState(prompt: "")
        s.buffer = "Hello world"
        s.location = s.currentBuffer.endIndex
        
        expect(s.deletePreviousWord()).to(beTrue())
        expect(s.buffer).to(equal("Hello "))
        expect(s.location).to(equal("Hello ".endIndex))
        
        s.buffer = ""
        s.location = s.currentBuffer.endIndex
        
        expect(s.deletePreviousWord()).to(beFalse())
        
        // Test with cursor location in the middle of the text
        s.buffer = "This is a test"
        s.location = s.currentBuffer.index(s.currentBuffer.startIndex, offsetBy: 8)
        
        expect(s.deletePreviousWord()).to(beTrue())
        expect(s.buffer).to(equal("This a test"))
    }
    
    func testDeleteToEndOfLine() {
        let s = EditState(prompt: "")
        s.buffer = "Hello world"
        s.location = s.currentBuffer.endIndex
        
        expect(s.deleteToEndOfLine()).to(beFalse())
        
        s.location = s.currentBuffer.index(s.currentBuffer.startIndex, offsetBy: 5)
        
        expect(s.deleteToEndOfLine()).to(beTrue())
        expect(s.currentBuffer).to(equal("Hello"))
    }
    
    func testDeleteCharacter() {
        let s = EditState(prompt: "")
        s.buffer = "Hello world"
        s.location = s.currentBuffer.endIndex
        
        expect(s.deleteCharacter()).to(beFalse())
        
        s.location = s.currentBuffer.startIndex
        
        expect(s.deleteCharacter()).to(beTrue())
        expect(s.currentBuffer).to(equal("ello world"))
        
        s.location = s.currentBuffer.index(s.currentBuffer.startIndex, offsetBy: 5)
        
        expect(s.deleteCharacter()).to(beTrue())
        expect(s.currentBuffer).to(equal("ello orld"))
    }
    
    
}
