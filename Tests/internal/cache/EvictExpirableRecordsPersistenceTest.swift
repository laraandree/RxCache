// EvictExpirableRecordsPersistenceTest.swift
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
import RxSwift

@testable import RxCache

class EvictExpirableRecordsPersistenceTest : XCTestCase {
    fileprivate var evictExpirableRecordsPersistenceUT : EvictExpirableRecordsPersistence!
    fileprivate var persistence : Disk!

    override func setUp() {
        super.setUp()
        
        persistence = Disk()
        
        persistence.evictAll()
        expect(self.persistence.allKeys().count).to(equal(0))
        
        evictExpirableRecordsPersistenceUT = EvictExpirableRecordsPersistence(persistence : persistence)
    }
    
    override func tearDown() {
        persistence.evictAll()
        super.tearDown()
    }
    
    func testWhenNotReachedMemoryThresholdNotEmit() {
        let maxMgPersistenceCache = 10
        evictExpirableRecordsPersistenceUT.maxMgPersistenceCache = maxMgPersistenceCache
        populate(true)
        expect(Double(self.persistence.allKeys().count)).to(beCloseTo(mocksCount(), within: 5.0))
        
        evictExpirableRecordsPersistenceUT.startTaskIfNeeded()
        
        let expectedStoredMB = (Double(maxMgPersistenceCache) * EvictExpirableRecordsPersistence.PercentageMemoryStoredToStop)
        expect(self.persistence.storedMB()).toEventually(beTruthy())
        expect(Double(self.persistence.storedMB()!)).toEventually(beCloseTo(expectedStoredMB, within: 2.0))
    }
    
    func testWhenReachedMemory3ThresholdPerformTask() {
        WhenReachedMemoryThresholdPerformTask(3)
    }
    
    func testWhenReachedMemory5ThresholdPerformTask() {
        WhenReachedMemoryThresholdPerformTask(5)
    }
    
    func testWhenReachedMemory7ThresholdPerformTask() {
        WhenReachedMemoryThresholdPerformTask(7)
    }
    
    func WhenReachedMemoryThresholdPerformTask(_ maxMgPersistenceCache: Int) {
        evictExpirableRecordsPersistenceUT.maxMgPersistenceCache = maxMgPersistenceCache
        
        populate(true)        
        expect(Double(self.persistence.allKeys().count)).to(beCloseTo(mocksCount(), within: 5))
        
        evictExpirableRecordsPersistenceUT.startTaskIfNeeded()
        expect(self.evictExpirableRecordsPersistenceUT.couldBeExpirableRecords).to(equal(true))
        
        let expectedStoredMB = (Double(maxMgPersistenceCache) * EvictExpirableRecordsPersistence.PercentageMemoryStoredToStop)
        expect(self.persistence.storedMB()).toEventually(beTruthy(), timeout: 5)
        
        expect(Double(self.persistence.storedMB()!)).toEventually(beCloseTo(expectedStoredMB, within: 2), timeout: 2)
    }
    
    func testWhenReachedMemoryThresholdButNotExpirableRecordsDoNotEvict() {
        let maxMgPersistenceCache = 5
        
        evictExpirableRecordsPersistenceUT.maxMgPersistenceCache = maxMgPersistenceCache
        populate(false)
        expect(Double(self.persistence.allKeys().count)).to(beCloseTo(mocksCount(), within: 5))
        
        evictExpirableRecordsPersistenceUT.startTaskIfNeeded()
        expect(self.evictExpirableRecordsPersistenceUT.couldBeExpirableRecords).toEventually(equal(false))

        expect(self.persistence.storedMB()).toEventually(beTruthy(), timeout: 5)
        expect(self.persistence.storedMB()!).toEventually(equal(sizeMbDataPopulated()))
    }
    
    //8 mb
    fileprivate func populate(_ expirable : Bool) {
        for index in 1...Int(mocksCount()) {
            var mocks = [Mock]()
            
            for _ in 1...Int(mocksCount()) {
                let mock = Mock(aString: "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                    "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC.")
                mocks.append(mock)
            }
            
            let record : Record<Mock> = Record(cacheables: mocks, lifeTimeInSeconds: 1, isExpirable: expirable)
            persistence.saveRecord(String(index), record: record)
        }
    }
    
    
    fileprivate func mocksCount() -> Double {
        return 100
    }
    
    fileprivate func sizeMbDataPopulated() -> Int {
        return 8
    }
}
