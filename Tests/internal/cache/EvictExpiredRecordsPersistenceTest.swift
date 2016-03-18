// EvictExpiredRecordsPersistenceTest.swift
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

class EvictExpiredRecordsPersistenceTest : XCTestCase {
    
    private var twoLayersCache : TwoLayersCache!
    private var evictExpiredRecordsPersistenceUT : EvictExpiredRecordsPersistence!
    private let oneSecond = LifeCache(duration: 1, timeUnit: LifeCache.TimeUnit.Seconds)
    private let thirtySecond = LifeCache(duration: 30, timeUnit: LifeCache.TimeUnit.Seconds)
    private let moreThanOneSecond : Double = 1.5
    private var persistence : Persistence!
    
    override func setUp() {
        super.setUp()
        
        persistence = Disk()
        twoLayersCache = TwoLayersCache(persistence: persistence)
        twoLayersCache.evictAll()
        
        evictExpiredRecordsPersistenceUT = EvictExpiredRecordsPersistence(persistence: persistence)
        
        expect(self.persistence.allKeys().count).to(equal(0))
    }
    
    override func tearDown() {
        super.tearDown()
        twoLayersCache.evictAll()
    }
    
    func testEvictJustExpiredRecords() {
        let recordsCount = 100
        for index in 1...recordsCount/2 {
            let keyExpired = String(index) + "_expired"

            twoLayersCache.save(keyExpired, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: data(keyExpired), lifeCache: oneSecond, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache)
            
            let keyLive = String(index) + "_live"
            twoLayersCache.save(keyLive, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: data(keyLive), lifeCache: thirtySecond, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache)
        }
        
        NSThread.sleepForTimeInterval(moreThanOneSecond)
        expect(self.persistence.allKeys().count).to(equal(recordsCount))
    
        var completed = false
        var valueCount = 0
        var error = false
        evictExpiredRecordsPersistenceUT.startEvictingExpiredRecords()
            .subscribe(onNext: { (_) -> Void in
                valueCount++
                }, onError: { (_) -> Void in
                    error = true
                }, onCompleted: { () -> Void in
                    completed = true
                }, onDisposed: { () -> Void in
                    
            }).addDisposableTo(DisposeBag())

        expect(completed).toEventually(equal(true))
        expect(error).toEventually(equal(false))
        expect(valueCount).toEventually(equal(recordsCount / 2))

        let allkeys = self.persistence.allKeys()
        expect(allkeys.count).to(equal(recordsCount / 2))

        allkeys.forEach { (key) -> () in
            let parts = key.componentsSeparatedByString("$")
            let realKey = parts[0]
            
            let record : Record<Mock> = twoLayersCache.retrieve(realKey, dynamicKey: nil, dynamicKeyGroup: nil,useExpiredDataIfLoaderNotAvailable: false, lifeCache: thirtySecond)!
            
            XCTAssert(record.cacheables[0].aString!.containsString("live"))
            XCTAssert(!record.cacheables[0].aString!.containsString("expired"))
        }
    }
    
    private func data(value: String) -> [Mock] {
        return [Mock(aString: value)]
    }
    
    func testCallOnCompleteWhenNoRecordsToEvict() {
        var completed = false
        var valueCount = 0
        var error = false
        evictExpiredRecordsPersistenceUT.startEvictingExpiredRecords()
            .subscribe(onNext: { (_) -> Void in
                valueCount++
                }, onError: { (_) -> Void in
                    error = true
                }, onCompleted: { () -> Void in
                    completed = true
                }, onDisposed: { () -> Void in
                    
            }).addDisposableTo(DisposeBag())
        expect(completed).toEventually(equal(true))
        expect(error).toEventually(equal(false))
        expect(valueCount).toEventually(equal(0))
    }
}