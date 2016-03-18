// ProvidersDynamicsKeysRxCacheTest.swift
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

class ProvidersDynamicsKeysRxCacheTest : XCTestCase {
    var providers : RxCache!
    let Size = 100
    
    let filter1Page1 = "filer1_page1"
    let filter1Page2 = "filer1_page2"
    let filter1Page3 = "filer1_page3"
    let filter2Page1 = "filer2_page1"
    let filter2Page2 = "filer2_page2"
    let filter2Page3 = "filer2_page3"
    
    override class func initialize () {
        RxCache.Providers.twoLayersCache.evictAll()
    }
    
    override func setUp() {
        super.setUp()
        providers = RxCache.Providers
    }

    
    func test1Pagination() {
        let providerPage1 = RxProvidersMock.GetMocksPaginate(page: 1)
        let providerPage2 = RxProvidersMock.GetMocksPaginate(page: 2)
        let providerPage3 = RxProvidersMock.GetMocksPaginate(page: 3)
        let mocks1 = createMocks(Size)
        let mockPage1Value = mocks1[0].aString!
        NSThread.sleepForTimeInterval(0.1)
        
        var success = false
        providers.cache(Observable.just(mocks1), provider: providerPage1).subscribeNext {data in
            success = true
            expect(data.count).to(equal(self.Size))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        let mocks2 = createMocks(Size)
        let mockPage2Value = mocks2[0].aString!
        NSThread.sleepForTimeInterval(0.1)
        
        success = false
        providers.cache(Observable.just(mocks2), provider: providerPage2).subscribeNext {data in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        let mocks3 = createMocks(Size)
        let mockPage3Value = mocks3[0].aString!
        
        success = false
        providers.cache(Observable.just(mocks3), provider: providerPage3).subscribeNext {data in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        success = false
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerPage1).subscribeNext {data in
            success = true
            expect(data[0].aString).to(equal(mockPage1Value))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        success = false
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerPage2).subscribeNext {data in
            success = true
            expect(data[0].aString).to(equal(mockPage2Value))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        success = false
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerPage3).subscribeNext {data in
            success = true
            expect(data[0].aString).to(equal(mockPage3Value))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
    }
    
    func test2PaginationEvictAll() {
        let providerPage1NoEvict = RxProvidersMock.GetMocksPaginateEvictAll(page: 1, evictAll: false)
        let providerPage2NoEvict = RxProvidersMock.GetMocksPaginateEvictAll(page: 2, evictAll: false)
        let providerEvictAll = RxProvidersMock.GetMocksPaginateEvictAll(page: 1, evictAll: true)
        
        var success = false
        providers.cache(createObservableMocks(Size), provider: providerPage1NoEvict).subscribeNext {data in
            success = true
            expect(data.count).to(equal(self.Size))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        success = false
        providers.cache(createObservableMocks(Size), provider: providerPage2NoEvict).subscribeNext {data in
            success = true
            expect(data.count).to(equal(self.Size))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        success = false
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerPage1NoEvict).subscribeNext {data in
            success = true
            expect(data.count).to(equal(self.Size))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        success = false
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerPage2NoEvict).subscribeNext {data in
            success = true
            expect(data.count).to(equal(self.Size))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerEvictAll).subscribeNext {data in}.addDisposableTo(DisposeBag())
        
        success = false
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerPage1NoEvict).subscribeError { (error) -> Void in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        success = false
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerPage2NoEvict).subscribeError { (error) -> Void in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
    }
    
    func test3PaginationEvictByPage() {
        let providerPage1NoEvict = RxProvidersMock.GetMocksPaginateEvictByPage(page: 1, evictByPage: false)
        let providerPage2NoEvict = RxProvidersMock.GetMocksPaginateEvictByPage(page: 2, evictByPage: false)
        let providerPage1Evict = RxProvidersMock.GetMocksPaginateEvictByPage(page: 1, evictByPage: true)
        
        var success = false
        providers.cache(createObservableMocks(Size), provider: providerPage1NoEvict).subscribeNext {data in
            success = true
            expect(data.count).to(equal(self.Size))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        success = false
        providers.cache(createObservableMocks(Size), provider: providerPage2NoEvict).subscribeNext {data in
            success = true
            expect(data.count).to(equal(self.Size))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerPage1Evict).subscribeNext {data in}.addDisposableTo(DisposeBag())
        
        success = false
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerPage1NoEvict).subscribeError { (error) -> Void in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        success = false
        providers.cache(RxCache.errorObservable([Mock].self), provider: providerPage2NoEvict).subscribeNext {data in
            success = true
            expect(data.count).to(equal(self.Size))
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
        
        providers.twoLayersCache.evictAll()
    }
    
    func test5PaginationFilteringEvictingDynamicKeyGroup() {
        populateAndCheckRetrieved()
        
        evictDynamicKeyGroup(filter1Page1)
        retrieveAndCheckFilterPageValue(filter1Page1, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter1Page2, shouldThrowException: false)
        retrieveAndCheckFilterPageValue(filter1Page3, shouldThrowException: false)
        retrieveAndCheckFilterPageValue(filter2Page1, shouldThrowException: false)
        
        evictDynamicKeyGroup(filter1Page2)
        retrieveAndCheckFilterPageValue(filter1Page2, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter1Page3, shouldThrowException: false)
        retrieveAndCheckFilterPageValue(filter2Page2, shouldThrowException: false)
        
        evictDynamicKeyGroup(filter1Page3)
        retrieveAndCheckFilterPageValue(filter1Page3, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter2Page3, shouldThrowException: false)
        
        evictDynamicKeyGroup(filter2Page1)
        retrieveAndCheckFilterPageValue(filter2Page1, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter2Page2, shouldThrowException: false)
        retrieveAndCheckFilterPageValue(filter2Page3, shouldThrowException: false)
        
        evictDynamicKeyGroup(filter2Page2)
        retrieveAndCheckFilterPageValue(filter2Page2, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter2Page3, shouldThrowException: false)
        
        evictDynamicKeyGroup(filter2Page3)
        retrieveAndCheckFilterPageValue(filter2Page3, shouldThrowException: true)
        
        populateAndCheckRetrieved()
        
        providers.twoLayersCache.evictAll()
    }
    
    func test6PaginationFilteringEvictingDynamicKey() {
        populateAndCheckRetrieved()
        
        evictDynamicKey(filter1Page2)
        retrieveAndCheckFilterPageValue(filter1Page1, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter1Page2, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter1Page3, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter2Page1, shouldThrowException: false)
        
        evictDynamicKey(filter2Page1)
        retrieveAndCheckFilterPageValue(filter2Page1, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter2Page2, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter2Page3, shouldThrowException: true)
        
        populateAndCheckRetrieved()
        
        providers.twoLayersCache.evictAll()
    }
    
    func test7PaginationFilteringEvictingProviderKey() {
        populateAndCheckRetrieved()
        
        evictProviderKey(filter1Page2)
        retrieveAndCheckFilterPageValue(filter1Page1, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter1Page2, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter1Page3, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter2Page1, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter2Page2, shouldThrowException: true)
        retrieveAndCheckFilterPageValue(filter2Page3, shouldThrowException: true)
        
        populateAndCheckRetrieved()

        providers.twoLayersCache.evictAll()
    }
    
    private func populateAndCheckRetrieved() {
        populateFilterPage(filter1Page1)
        populateFilterPage(filter1Page2)
        populateFilterPage(filter1Page3)
        populateFilterPage(filter2Page1)
        populateFilterPage(filter2Page2)
        populateFilterPage(filter2Page3)
        
        retrieveAndCheckFilterPageValue(filter1Page1, shouldThrowException: false)
        retrieveAndCheckFilterPageValue(filter1Page2, shouldThrowException: false)
        retrieveAndCheckFilterPageValue(filter1Page3, shouldThrowException: false)
        retrieveAndCheckFilterPageValue(filter2Page1, shouldThrowException: false)
        retrieveAndCheckFilterPageValue(filter2Page2, shouldThrowException: false)
        retrieveAndCheckFilterPageValue(filter2Page3, shouldThrowException: false)
    }
    
    
    private func populateFilterPage(filter_page: String) {
        let filer_pageArra = filter_page.componentsSeparatedByString("_")
        let filter = filer_pageArra[0]
        let page =  filer_pageArra[1]
        let provider = RxProvidersMock.GetMocksFilteredPaginateEvict(filter: filter, page: page, evict: EvictProvider(evict: false))

        var success = false
        let oMock : Observable<Mock> = Observable.just(Mock(aString: filter_page))
        
        providers.cache(oMock, provider: provider).subscribeNext {data in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
    }
    
    private func retrieveAndCheckFilterPageValue(filter_page: String, shouldThrowException : Bool) {
        let filer_pageArra = filter_page.componentsSeparatedByString("_")
        let filter = filer_pageArra[0]
        let page =  filer_pageArra[1]
        let provider = RxProvidersMock.GetMocksFilteredPaginateEvict(filter: filter, page: page, evict: EvictProvider(evict: false))
        
        var success = false
        
        if shouldThrowException {
            providers.cache(RxCache.errorObservable([Mock].self), provider: provider).subscribeError { (error) -> Void in
                success = true
                }.addDisposableTo(DisposeBag())
            expect(success).toEventually(equal(true))
        } else {
            providers.cache(RxCache.errorObservable([Mock].self), provider: provider).subscribeNext {data in
                success = true
                expect(data[0].aString).to(equal(filter_page))
                }.addDisposableTo(DisposeBag())
            expect(success).toEventually(equal(true))
        }
    }
    
    private func evictProviderKey(filter_page: String) {
        let filer_pageArra = filter_page.componentsSeparatedByString("_")
        let filter = filer_pageArra[0]
        let page =  filer_pageArra[1]
        let provider = RxProvidersMock.GetMocksFilteredPaginateEvict(filter: filter, page: page, evict: EvictProvider(evict: true))
        
        var success = false
        
        providers.cache(RxCache.errorObservable([Mock].self), provider: provider).subscribeError { (error) -> Void in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
    }
    
    private func evictDynamicKey(filter_page: String) {
        let filer_pageArray = filter_page.componentsSeparatedByString("_")
        let filter = filer_pageArray[0]
        let page =  filer_pageArray[1]
        let provider = RxProvidersMock.GetMocksFilteredPaginateEvict(filter: filter, page: page, evict: EvictDynamicKey(evict: true))
        var success = false
        
        providers.cache(RxCache.errorObservable([Mock].self), provider: provider).subscribeError { (error) -> Void in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
    }
    
    private func evictDynamicKeyGroup(filter_page: String) {
        let filer_pageArra = filter_page.componentsSeparatedByString("_")
        let filter = filer_pageArra[0]
        let page =  filer_pageArra[1]
        let provider = RxProvidersMock.GetMocksFilteredPaginateEvict(filter: filter, page: page, evict: EvictDynamicKeyGroup(evict: true))
        var success = false
        
        providers.cache(RxCache.errorObservable([Mock].self), provider: provider).subscribeError { (error) -> Void in
            success = true
            }.addDisposableTo(DisposeBag())
        expect(success).toEventually(equal(true))
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