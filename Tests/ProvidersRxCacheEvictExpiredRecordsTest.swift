// ProvidersRxCacheEvictExpiredRecordsTest.swift
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

let persistence : Persistence = Disk()

class ProvidersRxCacheEvictExpiredRecordsTest : XCTestCase {
    var providers : RxCache!

    override class func initialize () {
        RxCache.Providers.twoLayersCache.evictAll()
    }
    
    override func setUp() {
        super.setUp()
        providers = RxCache.Providers
    }
    
    func test1PopulateDiskWithExpiredRecordsButNoRetrievableKeys() {
        expect(Double(persistence.storedMB()!)).to(beCloseTo(0, within: 2))
        
        for index in 1...100 {
            var finish = false
            providers.cache(createObservableMocks(100), provider: RxProvidersMock.getEphemeralMocksPaginate(page: String(index))).subscribeNext { mocks in
                finish = true
            }.addDisposableTo(DisposeBag())
            
            expect(finish).toEventually(equal(true))
        }
        
        XCTAssert(persistence.storedMB()! > 0)
    }
    
    func test2PerformEvictingTaskAndCheckResults() {
        XCTAssert(persistence.storedMB()! > 0)
        
        providers.evictExpiredRecordsPersistence.startEvictingExpiredRecords()
            .subscribeCompleted {_ in}
            .addDisposableTo(DisposeBag())
        
        expect(Double(persistence.storedMB()!)).to(beCloseTo(0, within: 1.5))
    }
    
    func test3PopulateDiskWithNoExpiredRecordsButNoRetrievableKeys() {
        expect(Double(persistence.storedMB()!)).to(beCloseTo(0, within: 1.5))
        
        for index in 1...100 {
            var finish = false
            providers.cache(createObservableMocks(100), provider: RxProvidersMock.getMocksPaginate(page: index)).subscribeNext { mocks in
                finish = true
                }.addDisposableTo(DisposeBag())
            
            expect(finish).toEventually(equal(true))
        }
        
        XCTAssert(persistence.storedMB()! > 0)
    }
    
    func test4PerformEvictingTaskAndCheckResults() {
        XCTAssert(persistence.storedMB()! > 0)
        
        providers.evictExpiredRecordsPersistence.startEvictingExpiredRecords()
            .subscribeCompleted {_ in}
            .addDisposableTo(DisposeBag())
        
        expect(persistence.storedMB()).notTo(equal(0))
        RxCache.Providers.twoLayersCache.evictAll()
    }
    
    fileprivate func createObservableMocks(_ size : Int) -> Observable<[Mock]> {
        return Observable.just(createMocks(size))
    }
    
    fileprivate func createMocks(_ size : Int) -> [Mock] {
        var mocks = [Mock]()
        
        for _ in 1...size {
            mocks.append(Mock(aString: "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old"))
        }
        
        return mocks
    }
}
