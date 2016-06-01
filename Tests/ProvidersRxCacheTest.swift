// ProvidersRxCacheTest.swift
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

class ProvidersRxCacheTest : XCTestCase {
    var providers : RxCache!
    let Size = 100
    
    override class func initialize () {
        RxCache.Providers.twoLayersCache.evictAll()
    }
    
    override func setUp() {
        super.setUp()
        providers = RxCache.Providers
    }
    
    func test0Observable() {
        let provider = RxProvidersMock.GetMock()
        let mock = Mock(aString: "1")
        
        var success = false
        providers.cacheWithReply(Observable.just(mock), provider: provider).subscribeNext {reply in
            success = true
            expect(reply.cacheables.aString).to(equal("1"))
            expect(reply.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))

        success = false
        providers.cache(Observable.just(mock), provider: provider).subscribeNext {mock in
            success = true
            expect(mock.aString).to(equal("1"))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(equal(true))
    }
    
    func test1BeforeDestroyMemory() {
        let provider = RxProvidersMock.GetMocksWithDetailResponse()
        
        var success = false
        providers.cacheWithReply(createObservableMocks(Size), provider: provider).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))

        success = false
        providers.cacheWithReply(createObservableMocks(Size), provider: provider).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Memory.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))

        providers.twoLayersCache.mockMemoryDestroyed()
    }

    func test2AfterMemoryDestroyed() {
        let provider = RxProvidersMock.GetMocksWithDetailResponse()
        
        var success = false
        providers.cacheWithReply(createObservableMocks(Size), provider: provider).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Persistence.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))

        
        let providerOneSecond = RxProvidersMock.GetMocksResponseOneSecond()
        success = false
        providers.cacheWithReply(createObservableMocks(Size), provider: providerOneSecond).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))

        NSThread.sleepForTimeInterval(1.1)

        success = false
        providers.cacheWithReply(createObservableMocks(Size), provider: providerOneSecond).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))

        success = false
        providers.cacheWithReply(createObservableMocks(Size), provider: providerOneSecond).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Memory.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
    }
    
    func test3EvictingCache() {
        let providerEvict = RxProvidersMock.GetMocksEvictCache(evict: true)
        let providerNoEvict = RxProvidersMock.GetMocksEvictCache(evict: false)
        
        var success = false        
        providers.cacheWithReply(createObservableMocks(Size), provider: providerNoEvict).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))

        success = false
        providers.cacheWithReply(createObservableMocks(Size), provider: providerNoEvict).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Memory.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))

        success = false
        providers.cacheWithReply(createObservableMocks(Size), provider: providerEvict).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
    }
    
    func test4SessionMock() {
        let providerLoginEvict = RxProvidersMock.GetMocksLogin(Evict: true)
        let providerLoginNoEvict = RxProvidersMock.GetMocksLogin(Evict: false)
        let mock = Mock(aString: "aMockValue")
        
        //Not logged
        var success = false
        providers.cache(RxCache.errorObservable(Mock.self), provider: providerLoginNoEvict).subscribeError { (error) -> Void in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        //login
        success = false
        providers.cache(Observable.just(mock), provider: providerLoginEvict).subscribeNext {mock in
            success = true
            expect(mock.aString).to(equal("aMockValue"))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        //get logged mock
        success = false
        providers.cache(RxCache.errorObservable(Mock.self), provider: providerLoginNoEvict).subscribeNext {mock in
            success = true
            expect(mock.aString).to(equal("aMockValue"))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        RxCache.Providers.twoLayersCache.mockMemoryDestroyed()

        //logout
        success = false
        providers.cache(RxCache.errorObservable(Mock.self), provider: providerLoginEvict).subscribeError { (error) -> Void in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        //Not logged
        success = false
        providers.cache(RxCache.errorObservable(Mock.self), provider: providerLoginNoEvict).subscribeError { (error) -> Void in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
    }
    
    
    func test5UseExpiredData() {
        providers.twoLayersCache.evictAll()

        providers.useExpiredDataIfLoaderNotAvailable = true
        
        let providerOneSecond = RxProvidersMock.GetMocksResponseOneSecond()
        
        var success = false
        providers.cacheWithReply(createObservableMocks(Size), provider: providerOneSecond).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        NSThread.sleepForTimeInterval(1.1)
        
        success = false
        providers.cacheWithReply(RxCache.errorObservable([Mock].self), provider: providerOneSecond).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Memory.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        providers.twoLayersCache.evictAll()
    }
    
    func test6NoUseExpiredData() {
        providers.twoLayersCache.evictAll()

        providers.useExpiredDataIfLoaderNotAvailable = false
        
        let providerOneSecond = RxProvidersMock.GetMocksResponseOneSecond()
        
        var success = false
        providers.cacheWithReply(createObservableMocks(Size), provider: providerOneSecond).subscribeNext {reply in
            success = true
            expect(reply.cacheables.count).to(equal(self.Size))
            expect(reply.source.rawValue).to(equal(Source.Cloud.rawValue))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        NSThread.sleepForTimeInterval(1.1)
        
        success = false
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerOneSecond).subscribeError { (error) -> Void in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        providers.twoLayersCache.evictAll()
    }
    
    func test6WhenEvictAllThenEvictAll() {
        providers.twoLayersCache.evictAll()
        
        providers.useExpiredDataIfLoaderNotAvailable = false
        
        let providerOneSecond = RxProvidersMock.GetMocksResponseOneSecond()
    
        var success = false
        
        // Cache some data
        providers.cacheWithReply(createObservableMocks(Size), provider: providerOneSecond)
            .subscribeNext { reply in
                expect(reply.cacheables.count).to(equal(self.Size))
            }.addDisposableTo(DisposeBag())
        
        // Evict all
        providers.evictAll()
            .subscribe()
            .addDisposableTo(DisposeBag())

        // Retrieve no data
        providers.cacheWithReply(RxCache.errorObservable([Mock].self), provider: providerOneSecond)
            .subscribeError { error in
                success = true
            }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(equal(true))
        
        providers.twoLayersCache.evictAll()
    }
    
    func test7WhenAskForADeepCopyWithClassGetOne() {
        let getDeepCopy = GetDeepCopy()
        let mocks = createMocks(3)
        let mocksDeepCopy = getDeepCopy.getDeepCopy(mocks)
        mocks.first?.aString = "modifiedAString"
        expect(mocks.first?.aString).notTo(equal(mocksDeepCopy.first?.aString))
    }
    
    func test8WhenAskCacheFromMemoryGetsADeepCopyOfReply() {
        providers.twoLayersCache.evictAll()
        
        providers.useExpiredDataIfLoaderNotAvailable = false
        
        let providerOneSecond = RxProvidersMock.GetMocksResponseOneSecond()
        
        let modifiedAString = "ModifiedAString"
        
        var success = false
        providers.cacheWithReply(createObservableMocks(Size), provider: providerOneSecond)
            .map { (reply) -> Reply<[Mock]> in
                // Modify reply object
                reply.cacheables.first!.aString = modifiedAString
                return reply
        }.flatMap { reply in
            // Get reply from memory cache
            return self.providers.cacheWithReply(RxCache.errorObservable([Mock].self), provider: providerOneSecond)
        }.subscribeNext({ (reply) -> Void in
            success = true
            expect(reply.cacheables.first!.aString).notTo(equal(modifiedAString))
        }).addDisposableTo(DisposeBag())
        
        expect(success).toEventually(equal(true))
        
        providers.twoLayersCache.evictAll()
    }
    
    private func createObservableMocks(size : Int) -> Observable<[Mock]> {
        return Observable.just(createMocks(size))
    }
    
    private func createMocks(size : Int) -> [Mock] {
        var mocks = [Mock]()
        
        for index in 1...size {
            let nowDouble = NSDate().timeIntervalSince1970
            mocks.append(Mock(aString: String(Int64(nowDouble*1000)+index)))
        }
        
        return mocks
    }
    
}
