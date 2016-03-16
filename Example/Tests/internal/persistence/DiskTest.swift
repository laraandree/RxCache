// DiskOMTest.swift
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

class DiskTest: XCTestCase {
    private var diskUT : Disk!
    private let KeyRecords = "records", Key1 = "record1", Key2 = "record2"
    
    override class func initialize () {
        Disk().evictAll()
    }
    
    override func setUp() {
        super.setUp()
        diskUT = Disk()
    }
    
    func test1SaveRecordsOMMockEntity() {
        let records = getRecordsMock()
        var success = diskUT.saveRecord(Key1, record: records[0])
        expect(success).to(equal(true))
        
        success = diskUT.saveRecord(Key2, record: records[1])
        expect(success).to(equal(true))
        
        let arrayMocks : [Mock] = [records[0].rxObjects[0], records[1].rxObjects[0]]
        let recordContainingArray = Record(source: Source.Memory, rxObjects: arrayMocks, timeAtWhichWasPersisted : 0, lifeTimeInSeconds: 0)
        success = diskUT.saveRecord(KeyRecords, record: recordContainingArray)
        expect(success).to(equal(true))
    }
    
    func test2RetrieveRecords() {
        let record1 : Record<Mock> = diskUT.retrieveRecord(Key1)!
        expect(record1.source.rawValue).to(equal(Source.Memory.rawValue))
        expect(record1.rxObjects[0].aString).to(equal("1"))
        
        
        let record2 : Record<Mock> = diskUT.retrieveRecord(Key2)!
        expect(record2.source.rawValue).to(equal(Source.Persistence.rawValue))
        expect(record2.rxObjects[0].aString).to(equal("2"))
        expect(record2.rxObjects[0].mock!.aString).to(equal("1"))
        
        let recordContainingArray : Record<Mock> = diskUT.retrieveRecord(KeyRecords)!
        expect(record1.source.rawValue).to(equal(Source.Memory.rawValue))
        
        let mockContained1 : Mock = recordContainingArray.rxObjects[0]
        expect(mockContained1.aString).to(equal("1"))
        
        let mockContained2 : Mock = recordContainingArray.rxObjects[1]
        expect(mockContained2.aString).to(equal("2"))
    }
    
    func test3OverrideRecords() {
        let record1 : Record<Mock> = diskUT.retrieveRecord(Key1)!
        expect(record1.source.rawValue).to(equal(Source.Memory.rawValue))
        expect(record1.rxObjects[0].aString).to(equal("1"))
        
        let success = diskUT.saveRecord(Key1, record: getRecordsMock()[1])
        expect(success).to(equal(true))
        
        let record2 : Record<Mock> = diskUT.retrieveRecord(Key1)!
        expect(record2.source.rawValue).to(equal(Source.Persistence.rawValue))
        expect(record2.rxObjects[0].aString).to(equal("2"))
        expect(record2.rxObjects[0].mock!.aString).to(equal("1"))
    }
    
    func test4ClearRecords() {
        test1SaveRecordsOMMockEntity()
        test2RetrieveRecords()
        
        diskUT.evict(KeyRecords)
        diskUT.evict(Key1)
        diskUT.evict(Key2)
        
        let record1 : Record<Mock>? = diskUT.retrieveRecord(Key1)
        expect(record1).to(beNil())
        
        let record2 : Record<Mock>? = diskUT.retrieveRecord(Key2)
        expect(record2).to(beNil())
        
        let recordContainingArray : Record<Mock>? = diskUT.retrieveRecord(KeyRecords)
        expect(recordContainingArray).to(beNil())
    }
    
    func test5ClearAllRecords() {
        test1SaveRecordsOMMockEntity()
        test2RetrieveRecords()
        
        diskUT.evictAll()
        
        let record1 : Record<Mock>? = diskUT.retrieveRecord(Key1)
        expect(record1).to(beNil())
        
        let record2 : Record<Mock>? = diskUT.retrieveRecord(Key2)
        expect(record2).to(beNil())
        
        let recordContainingArray : Record<Mock>? = diskUT.retrieveRecord(KeyRecords)
        expect(recordContainingArray).to(beNil())
        
        Disk().evictAll()
    }
    
    func getRecordsMock() -> [Record<Mock>] {
        let record1 : Record<Mock> = Record(source: Source.Memory, rxObjects: [Mock(aString: "1")], timeAtWhichWasPersisted : 2.32, lifeTimeInSeconds: 0)
        
        let mock2 = Mock(aString: "2")
        mock2.mock = record1.rxObjects[0]
        
        let record2 : Record<Mock> = Record(source: Source.Persistence, rxObjects: [mock2], timeAtWhichWasPersisted : 0, lifeTimeInSeconds: 0)
        
        return [record1, record2]
    }
}
