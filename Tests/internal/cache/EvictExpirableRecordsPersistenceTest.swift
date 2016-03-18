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
    private var evictExpirableRecordsPersistenceUT : EvictExpirableRecordsPersistence!
    private let oneMiliSecond : Double = 0.01
    private let noExpirable : Double = 0
    private var persistence : Disk!

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
    
//    func testWhenTaskIsRunningDoNotStartAgain() {
//        evictExpirableRecordsPersistenceUT.maxMgPersistenceCache = 10
//        
//        for _ in 1...10 {
//            evictExpirableRecordsPersistenceUT.startTaskIfNeeded()
//        }
//        
//        NSThread.sleepForTimeInterval(0.3)
//        expect(self.evictExpirableRecordsPersistenceUT.executedTasks).toEventually(beCloseTo(1, within: 2))
//    }
//    
//    func testWhenTaskIsNotRunningStartAgain() {
//        evictExpirableRecordsPersistenceUT.maxMgPersistenceCache = 10
//        
//        for _ in 1...10 {
//            NSThread.sleepForTimeInterval(0.3)
//            evictExpirableRecordsPersistenceUT.startTaskIfNeeded()
//        }
//        
//        expect(self.evictExpirableRecordsPersistenceUT.executedTasks).toEventually(equal(10))
//    }
//    
//    func testWhenNotReachedMemoryThresholdNotEmit() {
//        let maxMgPersistenceCache = 10
//        evictExpirableRecordsPersistenceUT.maxMgPersistenceCache = maxMgPersistenceCache
//        populate(true)
//        
//        expect(self.persistence.allKeys().count).to(beCloseTo(mocksCount(), within: 5))
//        
//        evictExpirableRecordsPersistenceUT.startTaskIfNeeded()
//        expect(self.evictExpirableRecordsPersistenceUT.executedTasks).toEventually(equal(1))
//        
//        let expectedStoredMB = Int((Double(maxMgPersistenceCache) * EvictExpirableRecordsPersistence.PercentageMemoryStoredToStop))
//        expect(self.persistence.storedMB()).toEventually(beTruthy())
//        
//        expect(self.persistence.storedMB()).toEventually(beCloseTo(expectedStoredMB, within: 2))
//    }
//    
//    func testWhenReachedMemory3ThresholdPerformTask() {
//        WhenReachedMemoryThresholdPerformTask(3)
//    }
//    
//    func testWhenReachedMemory5ThresholdPerformTask() {
//        WhenReachedMemoryThresholdPerformTask(5)
//    }
//    
//    func testWhenReachedMemory7ThresholdPerformTask() {
//        WhenReachedMemoryThresholdPerformTask(7)
//    }
//    
//    func WhenReachedMemoryThresholdPerformTask(maxMgPersistenceCache: Int) {
//        evictExpirableRecordsPersistenceUT.maxMgPersistenceCache = maxMgPersistenceCache
//        
//        populate(true)        
//        expect(self.persistence.allKeys().count).to(beCloseTo(mocksCount(), within: 5))
//        
//        evictExpirableRecordsPersistenceUT.startTaskIfNeeded()
//        expect(self.evictExpirableRecordsPersistenceUT.executedTasks).toEventually(equal(1))
//        expect(self.evictExpirableRecordsPersistenceUT.couldBeExpirableRecords).to(equal(true))
//        
//        let expectedStoredMB = Int((Double(maxMgPersistenceCache) * EvictExpirableRecordsPersistence.PercentageMemoryStoredToStop))
//        expect(self.persistence.storedMB()).toEventually(beTruthy(), timeout: 5)
//        
//        expect(self.persistence.storedMB()).toEventually(beCloseTo(expectedStoredMB, within: 2), timeout: 2)
//    }
//    
//    func testWhenReachedMemoryThresholdButNotExpirableRecordsDoNotEvict() {
//        let maxMgPersistenceCache = 5
//        
//        evictExpirableRecordsPersistenceUT.maxMgPersistenceCache = maxMgPersistenceCache
//        populate(false)
//        expect(self.persistence.allKeys().count).to(beCloseTo(mocksCount(), within: 5))
//        
//        evictExpirableRecordsPersistenceUT.startTaskIfNeeded()
//        expect(self.evictExpirableRecordsPersistenceUT.executedTasks).toEventually(equal(1))
//        expect(self.evictExpirableRecordsPersistenceUT.couldBeExpirableRecords).toEventually(equal(false))
//
//        expect(self.persistence.storedMB()).toEventually(beTruthy(), timeout: 5)
//        expect(self.persistence.storedMB()!).toEventually(equal(sizeMbDataPopulated()))
//    }
    
    //8 mb
    private func populate(expirable : Bool) {
        for index in 1...mocksCount() {
            var mocks = [Mock]()
            
            for _ in 1...mocksCount() {
                let mock = Mock(aString: "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                    "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC.")
                mocks.append(mock)
            }
            
            let lifeTime = expirable == true ? oneMiliSecond : noExpirable
            let record : Record<Mock> = Record(cacheables: mocks, lifeTimeInSeconds: lifeTime)
            
            persistence.saveRecord(String(index), record: record)
        }
    }
    
    
    private func mocksCount() -> Int {
        return 100
    }
    
    private func sizeMbDataPopulated() -> Int {
        return 8
    }
}