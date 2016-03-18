// ProvidersMappableTest.swift
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

class ProvidersTest: XCTestCase {
    private var providers : RxCache!
    private var persistence : Disk!
    
    override func setUp() {
        super.setUp()
        persistence = Disk()
        
        providers = RxCache.Providers
        providers.useExpiredDataIfLoaderNotAvailable = false
        providers.twoLayersCache.evictAll()
    }
    
    func testWhenFirstRetrieveThenSourceRetrievedIsCloud() {
        let mock = [Mock(aString: "1")]
        var success = false
        
        let provider = MockProvider.Mock(evict: nil, lifeCache: nil)
        providers.cacheArray(Observable.just(mock), provider: provider).subscribeNext {record in
            success = true
            expect(record.cacheables[0]).toNot(beNil())
            expect(record.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
    }
    
    func testWhenNoInvalidateCacheThenSourceRetrievedIsNotCloud() {
        let mock = [Mock(aString: "1")]
        var success = false
        
        let provider = MockProvider.Mock(evict: nil, lifeCache: nil)
        providers.cacheArray(Observable.just(mock), provider: provider).subscribeNext {record in
            success = true
            expect(record.cacheables[0]).toNot(beNil())
            expect(record.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        success = false
        providers.cacheArray(Observable.just(mock), provider: provider).subscribeNext {record in
            success = true
            expect(record.cacheables[0]).toNot(beNil())
            expect(record.source.rawValue).toNot(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
    }
    
    func testWhenInvalidateCacheThenSourceRetrievedIsCloud() {
        let mock = [Mock(aString: "1")]
        var success = false
        
        providers.cacheArray(Observable.just(mock), provider: MockProvider.Mock(evict: nil, lifeCache: nil)).subscribeNext {record in
            success = true
            expect(record.cacheables[0]).toNot(beNil())
            expect(record.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        let provider = MockProvider.Mock(evict: EvictProvider(evict: true), lifeCache: nil)
        success = false
        providers.cacheArray(Observable.just(mock), provider: provider).subscribeNext {record in
            success = true
            expect(record.cacheables[0]).toNot(beNil())
            expect(record.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
    }
    
    func testWhenLoaderThrowsExceptionAndThereIsNoCacheThenGetThrowException() {
        let loader : Observable<[Mock]> = Observable.error(NSError(domain: Locale.NotDataReturnWhenCallingObservableLoader, code: 0, userInfo: nil))
        
        let provider = MockProvider.Mock(evict: nil, lifeCache: nil)
        
        var errorThrown = false
        providers.cacheArray(loader, provider: provider)
            .subscribeError { (error) -> Void in
                errorThrown = true
            }.addDisposableTo(DisposeBag())
        
        expect(errorThrown).toEventually(equal(true))
    }
    
    func tetsWhenUselessLoaderAndCacheNoExpiredByLifeCache0ThenGetMock() {
        let lifeCache : LifeCache = LifeCache(duration: 0, timeUnit: LifeCache.TimeUnit.Seconds)
        whenUselessLoaderAndCacheNoExpiredThenGetMock(lifeCache)
    }
    
    func testWhenUselessLoaderAndCacheNoExpiredByLifeCacheNilThenGetMock() {
        whenUselessLoaderAndCacheNoExpiredThenGetMock(nil)
    }
    
    private func whenUselessLoaderAndCacheNoExpiredThenGetMock(lifeCache : LifeCache?) {
        let mock = [Mock(aString: "1")]
        
        var success = false
        providers.cacheArray(Observable.just(mock), provider: MockProvider.Mock(evict: nil, lifeCache: nil)).subscribeNext {record in
            success = true
            expect(record.cacheables[0]).toNot(beNil())
            expect(record.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        var errorThrown = true
        let provider = MockProvider.Mock(evict: nil, lifeCache: lifeCache)
        providers.cacheArray(RxCache.errorObservable([Mock].self), provider: provider).subscribeNext {record in
            expect(record.cacheables[0]).toNot(beNil())
            errorThrown = false
            }.addDisposableTo(DisposeBag())
        
        expect(errorThrown).toEventually(equal(false))
    }
    
    func testWhenUselessLoaderAndCacheInvalidateAndUseExpiredDataIfLoaderNotAvailableThenGetMock() {
        providers.useExpiredDataIfLoaderNotAvailable = true
        
        let mock = [Mock(aString: "1")]
        var success = false
        providers.cacheArray(Observable.just(mock), provider: MockProvider.Mock(evict: nil, lifeCache: nil)).subscribeNext {record in
            success = true
            expect(record.cacheables[0]).toNot(beNil())
            expect(record.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        var errorThrown = true
        
        let provider = MockProvider.Mock(evict: EvictProvider(evict: true), lifeCache: nil)
        providers.cacheArray(RxCache.errorObservable([Mock].self), provider: provider).subscribeNext {record in
            expect(record.cacheables[0]).toNot(beNil())
            errorThrown = false
            }.addDisposableTo(DisposeBag())
        
        expect(errorThrown).toEventually(equal(false))
    }
    
    func testWhenUselessLoaderAndCacheInvalidateButNoUseExpiredDataIfLoaderNotAvailableThenGetException() {
        providers.useExpiredDataIfLoaderNotAvailable = false
        
        let mock = [Mock(aString: "1")]
        var success = false
        providers.cacheArray(Observable.just(mock), provider: MockProvider.Mock(evict: nil, lifeCache: nil)).subscribeNext {record in
            success = true
            expect(record.cacheables[0]).toNot(beNil())
            expect(record.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        let provider = MockProvider.Mock(evict: EvictProvider(evict: true), lifeCache: nil)
        var errorThrown = false
        providers.cacheArray(RxCache.errorObservable([Mock].self), provider: provider).subscribeError { (error) -> Void in
            errorThrown = true
            }.addDisposableTo(DisposeBag())
        
        expect(errorThrown).toEventually(equal(true))
    }
    
    func testWhenCacheIsCalledObservableIsDeferredUntilSubscription() {
        self.providers.twoLayersCache.retrieveHasBeenCalled = false
        
        let provider = MockProvider.Mock(evict: nil, lifeCache: nil)
        let mock = [Mock(aString: "1")]
        let oMock = providers.cacheArray(Observable.just(mock), provider: provider)
        
        expect(self.providers.twoLayersCache.retrieveHasBeenCalled).to(equal(false))
        oMock.subscribeNext{_ in}.addDisposableTo(DisposeBag())
        expect(self.providers.twoLayersCache.retrieveHasBeenCalled).toEventually(equal(true))
    }
    
    func testWhenUseEvictDynamicKeyWithoutProvidingDynamicKeyGetException() {
        let mock = [Mock(aString: "1")]
        
        var errorThrown = false
        providers.cacheArray(Observable.just(mock), provider: MockProviderEvictDynamicKey.Error()).subscribeError { (error) -> Void in
            errorThrown = true
            }.addDisposableTo(DisposeBag())
        
        expect(errorThrown).toEventually(equal(true))
        
        providers.cacheArray(Observable.just(mock), provider: MockProviderEvictDynamicKey.Success())
            .subscribeNext {record in
                errorThrown = false
                expect(record.cacheables[0]).toNot(beNil())
            }.addDisposableTo(DisposeBag())
        expect(errorThrown).toEventually(equal(false))
    }
    
    func testWhenUseEvictDynamicKeyGroupWithoutProvidingDynamicKeyGroupGetException() {
        let mock = [Mock(aString: "1")]
        
        var errorThrown = false
        providers.cacheArray(Observable.just(mock), provider: MockProviderEvictDynamicKeyGroup.Error())
            .subscribeError { (error) -> Void in
                errorThrown = true
            }.addDisposableTo(DisposeBag())
        expect(errorThrown).toEventually(equal(true))
        
        providers.cacheArray(Observable.just(mock), provider: MockProviderEvictDynamicKeyGroup.Success())
            .subscribeNext {record in
                errorThrown = false
                expect(record.cacheables[0]).toNot(beNil())
            }.addDisposableTo(DisposeBag())
        expect(errorThrown).toEventually(equal(false))
    }
    
    enum MockProvider : Provider {
        case Mock(evict: EvictProvider?, lifeCache : LifeCache? )
        
        var lifeCache: LifeCache? {
            switch self {
            case let Mock(_, lifeCache):
                return lifeCache
            }
        }
        
        var dynamicKey: DynamicKey? {
            return nil
        }
        
        var dynamicKeyGroup: DynamicKeyGroup? {
            return nil
        }
        
        var evict: EvictProvider? {
            switch self {
            case let Mock(evict, _):
                return evict
            }
        }
    }
    
    enum MockProviderEvictDynamicKey : Provider {
        case Error()
        case Success()
        
        var lifeCache: LifeCache? {
            return nil
        }
        
        var dynamicKey: DynamicKey? {
            switch self {
            case Error():
                return nil
            case Success():
                return DynamicKey(dynamicKey: "1")
            }
        }
        
        var dynamicKeyGroup: DynamicKeyGroup? {
            return nil
        }
        
        var evict: EvictProvider? {
            return EvictDynamicKey(evict: true)
        }
    }
    
    enum MockProviderEvictDynamicKeyGroup : Provider {
        case Error()
        case Success()
        
        var lifeCache: LifeCache? {
            return nil
        }
        
        var dynamicKey: DynamicKey? {
            return nil
        }
        
        var dynamicKeyGroup: DynamicKeyGroup? {
            switch self {
            case Error():
                return nil
            case Success():
                return DynamicKeyGroup(dynamicKey: "1", group: "1")
            }
        }
        
        var evict: EvictProvider? {
            return EvictDynamicKeyGroup(evict: true)
        }
    }
}


