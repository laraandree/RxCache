//
//  ActionsTest.swift
//  RxCache
//
//  Created by Roberto Frontado on 5/3/16.
//  Copyright © 2016 victoralbertos. All rights reserved.
//

import XCTest
import RxSwift
import Nimble

@testable import RxCache

class ActionsTest: XCTestCase {
    private var providers : RxCache!
    private var persistence : Disk!
    private var actions: Actions<Mock>!
    
    override func setUp() {
        super.setUp()
        persistence = Disk()
        
        actions = Actions<Mock>.with(RxProvidersMock.GetMocksEvictCache(evict: false))
        
        providers = RxCache.Providers
        providers.useExpiredDataIfLoaderNotAvailable = false
        providers.twoLayersCache.evictAll()
    }
    
    // MARK: Add
    func test1AddAll() {
        checkInitialState()
        addAll(10)
    }
    
    func test2AddFirst() {
        var success = false
        checkInitialState()
        
        actions.addFirst(Mock(aString: "1"))
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(1))
                expect(mocks.first!.aString).to(equal("1"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func test3AddLast() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.addLast(Mock(aString: "11"))
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(11))
                expect(mocks.last!.aString).to(equal("11"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func test4Add() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.add({ (position, count) in position == 5 }, candidate: Mock(aString: "6_added"))
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(11))
                expect(mocks[5].aString).to(equal("6_added"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    // MARK: Evict
    func test4EvictFirst() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evictFirst()
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(9))
                expect(mocks.first!.aString).to(equal("1"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func test5EvictFirstExposingCount() {
        var success = false
        checkInitialState()
        addAll(10)
        
        // Do not evict
        actions.evictFirst { count in count > 10 }
            .toObservable()
            .subscribeNext { mocks in
                expect(mocks.count).to(equal(10))
        }
        
        // Evict
        actions.evictFirst { count in count > 9 }
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(9))
                expect(mocks.first!.aString).to(equal("1"))
        }
        
        expect(success).toEventually(beTrue())
    }

    func test6EvictLast() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evictLast()
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(9))
                expect(mocks.last!.aString).to(equal("8"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func test7EvictLastExposingCount() {
        var success = false
        checkInitialState()
        addAll(10)
        
        // Do not evict
        actions.evictLast { count in count > 10 }
            .toObservable()
            .subscribeNext { mocks in
                expect(mocks.count).to(equal(10))
        }
        
        // Evict
        actions.evictLast { count in count > 9 }
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(9))
                expect(mocks.last!.aString).to(equal("8"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func test8EvictExposingElementCurrentIteration() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evict { (element: Mock) in element.aString == "3"}
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(9))
                expect(mocks[3].aString).to(equal("4"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func test9EvictExposingCountAndPositionAndElementCurrentIteration() {
        var success = false
        checkInitialState()
        addAll(10)
        
        // Do not evict
        actions.evict { (position, count, element) in count > 10 && element.aString == "3" }
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(10))
                expect(mocks[3].aString).to(equal("3"))
        }
        
        // Evict
        actions.evict { (position, count, element) in count > 9 && element.aString == "3" }
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(10))
                expect(mocks[3].aString).to(equal("4"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func test10EvictIterable() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evictIterable{ (position, count, element) in
            element.aString == "2" || element.aString == "3" }
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(8))
                expect(mocks[2].aString).to(equal("4"))
                expect(mocks[3].aString).to(equal("5"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func test11EvictAll() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evictAll()
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(0))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    // MARK: Update
    func test12UpdateExposingElementCurrentIteration() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.update({ (element: Mock) in element.aString == "5" }
            , replace: { (element: Mock) in Mock(aString: "5_updated") })
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(10))
                expect(mocks[5].aString).to(equal("5_updated"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func test13UpdateExposingCountAndPositionAndElementCurrentIteration() {
        var success = false
        checkInitialState()
        addAll(10)
        
        // Do not evict
        actions.update({ (position, count, element) in count > 10 && element.aString == "5" }
            , replace: { (element) in Mock(aString: "5_updated") })
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(10))
                expect(mocks[5].aString).to(equal("5"))
        }
        
        // Evict
        actions.update({ (position, count, element) in count > 9 && element.aString == "5" }
            , replace: { (element) in Mock(aString: "5_updated") })
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(10))
                expect(mocks[5].aString).to(equal("5_updated"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func test14UpdateIterableExposingElementCurrentIteration() {
        var success = false
        checkInitialState()
        addAll(10)
        
        // Evict
        actions.updateIterable({ (element: Mock) in
            element.aString == "5" || element.aString == "6" }
            , replace: { (element: Mock) in Mock(aString: "5_or_6_updated") })
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(10))
                expect(mocks[5].aString).to(equal("5_or_6_updated"))
                expect(mocks[6].aString).to(equal("5_or_6_updated"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func test15UpdateIterableExposingCountAndPositionAndElementCurrentIteration() {
        var success = false
        checkInitialState()
        addAll(10)
        
        // Do not evict
        actions.updateIterable({ (position, count, element)  in
            count > 10 && (element.aString == "5" || element.aString == "6") }
            , replace: { (element: Mock) in Mock(aString: "5_or_6_updated") })
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(10))
                expect(mocks[5].aString).to(equal("5"))
                expect(mocks[6].aString).to(equal("6"))
        }
        
        // Evict
        actions.updateIterable({ (position, count, element)  in
            count > 9 && (element.aString == "5" || element.aString == "6") }
            , replace: { (element: Mock) in Mock(aString: "5_or_6_updated") })
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(10))
                expect(mocks[5].aString).to(equal("5_or_6_updated"))
                expect(mocks[6].aString).to(equal("5_or_6_updated"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    // MARK: - Private methods
    private func cache() -> Observable<[Mock]> {
        let provider = RxProvidersMock.GetMocksEvictCache(evict: false)
        return providers.cache(Observable.just([Mock]()), provider: provider)
    }
    
    private func checkInitialState() {
        var success = false
        
        cache().subscribeNext { mocks in
            success = true
            expect(mocks.count).to(equal(0))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    private func addAll(count: Int) {
        var success = false
        
        var mocks = [Mock]()
        
        for i in 0..<count {
            mocks.append(Mock(aString: "\(i)"))
        }
        
        actions.addAll({ (position, count) in position == count }, candidates: mocks)
            .toObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (mocks: [Mock]) in
                success = true
                expect(mocks.count).to(equal(count))
            })
        
        expect(success).toEventually(beTrue(), timeout: 20, pollInterval: 1, description: nil)
    }
    
}
