// MappingTest.swift
// RxCache
//
// Copyright (c) 2016 Victor Albertos https://github.com/VictorAlbertos
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
import Nimble

@testable import RxCache

class MappingTest: XCTestCase {
    private var diskUT : Disk!
    private let KeyRecords = "records", Key1 = "record1", Key2 = "record2"
    
    override class func initialize () {
        Disk().evictAll()
    }
    
    override func setUp() {
        super.setUp()
        diskUT = Disk()
        
    }

    func testMockGlossStruct() {
        let key = "key"
        let value = "MockGlossStruct"
        
        let mock  = MockGlossStruct(aString: value)
        let saveRecord : Record<MockGlossStruct> = Record(cacheables: [mock], lifeTimeInSeconds: 2.32)
        
        let success = diskUT.saveRecord(key, record: saveRecord)
        expect(success).to(equal(true))
        
        let retrievedRecord : Record<MockGlossStruct> = diskUT.retrieveRecord(key)!
        let valueRerievedMock = retrievedRecord.cacheables[0].aString
        expect(valueRerievedMock).to(equal(value))

        diskUT.evictAll()
    }
    
    func testMockGlossClass() {
        let key = "key"
        let value = "MockGlossClass"
        
        let mock  = MockGlossClass(aString: value)
        let saveRecord : Record<MockGlossClass> = Record(cacheables: [mock], lifeTimeInSeconds: 2.32)
        
        let success = diskUT.saveRecord(key, record: saveRecord)
        expect(success).to(equal(true))
        
        let retrievedRecord : Record<MockGlossClass> = diskUT.retrieveRecord(key)!
        let valueRerievedMock = retrievedRecord.cacheables[0].aString
        expect(valueRerievedMock).to(equal(value))
        
        diskUT.evictAll()
    }
    
    func testMockOmStruct() {
        let key = "key"
        let value = "MockOMStruct"
        
        let mock  = MockOMStruct(aString: value)
        let saveRecord : Record<MockOMStruct> = Record(cacheables: [mock], lifeTimeInSeconds: 2.32)
        
        let success = diskUT.saveRecord(key, record: saveRecord)
        expect(success).to(equal(true))
        
        let retrievedRecord : Record<MockGlossStruct> = diskUT.retrieveRecord(key)!
        let valueRerievedMock = retrievedRecord.cacheables[0].aString
        expect(valueRerievedMock).to(equal(value))
        
        diskUT.evictAll()
    }
    
    
    func testMockOmClass() {
        let key = "key"
        let value = "MockOMClass"
        
        let mock  = MockOMClass(aString: value)
        let saveRecord : Record<MockOMClass> = Record(cacheables: [mock], lifeTimeInSeconds: 2.32)
        
        let success = diskUT.saveRecord(key, record: saveRecord)
        expect(success).to(equal(true))
        
        let retrievedRecord : Record<MockGlossStruct> = diskUT.retrieveRecord(key)!
        let valueRerievedMock = retrievedRecord.cacheables[0].aString
        expect(valueRerievedMock).to(equal(value))
        
        diskUT.evictAll()
    }
    
}

