// ProvidersRxCacheEvictExpirableRecordsTest.swift
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
import RxSwift
import Nimble

@testable import RxCache

class ProvidersRxCacheEvictExpirableRecordsTest : XCTestCase {
    var providers : RxCache!
    private let maxMBPersistenceCache = 7
    
    override func setUp() {
        super.setUp()
        providers = RxCache.Providers
        RxCache.Providers.maxMBPersistenceCache = maxMBPersistenceCache
        RxCache.Providers.twoLayersCache.evictAll()
    }
    
    override func tearDown() {
        RxCache.Providers.twoLayersCache.evictAll()
        super.tearDown()
    }
    
    func testWhenExpirableRecordsEvict() {
        expect(persistence.storedMB()).to(beCloseTo(0, within: 1.5))
        
        for i in 1...50 {
            NSThread.sleepForTimeInterval(0.05)
            
            var finish = false
            providers.cache(createObservableMocks(), provider: RxProvidersMock.GetEphemeralMocksPaginate(page: String(i))).subscribeNext { mocks in
                finish = true
                }.addDisposableTo(DisposeBag())
            
            expect(finish).toEventually(equal(true))
        }
        
        let expectedStoredMB = Int(ceil((Double(maxMBPersistenceCache) * EvictExpirableRecordsPersistence.PercentageMemoryStoredToStop)))
        expect(persistence.storedMB()).toEventually(equal(expectedStoredMB))
    }
    
    func testWhenNoExpirableRecordsDoNotEvict() {
        expect(persistence.storedMB()).to(beCloseTo(0, within: 1.5))
        
        for i in 1...50 {
            NSThread.sleepForTimeInterval(0.05)
            
            var finish = false
            providers.cache(createObservableMocks(), provider: RxProvidersMock.GetMocksPaginate(page: i)).subscribeNext { mocks in
                finish = true
                }.addDisposableTo(DisposeBag())
            
            expect(finish).toEventually(equal(true))
        }
                
        expect(persistence.storedMB()).toEventually(equal(maxMBPersistenceCache))
    }
    
    func createObservableMocks() -> Observable<[Mock]> {
        var mocks = [Mock]()
        
        for _ in 1...100 {
            let mock = Mock(aString:"Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC." +
                "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                    "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC." +
                    "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                    "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC." +
                "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                    "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC." +
                "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                    "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC." +
                "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                    "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                    "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC.")
            mocks.append(mock)
        }
        
        return Observable.just(mocks)
    }
    
}