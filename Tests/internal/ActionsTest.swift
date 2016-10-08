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
    fileprivate var providers : RxCache!
    fileprivate var persistence : Disk!
    fileprivate var actions: Actions<Mock>!
    
    override func setUp() {
        super.setUp()
        persistence = Disk()
        
        actions = Actions<Mock>.with(RxProvidersMock.getMocksEvictCache(evict: false))
        
        providers = RxCache.Providers
        providers.useExpiredDataIfLoaderNotAvailable = false
        providers.twoLayersCache.evictAll()
    }
    
    // MARK: Add
    func testAddAll() {
        checkInitialState()
        addAll(10)
    }
    
    func testAddFirst() {
        var success = false
        checkInitialState()
        
        actions.addFirst(Mock(aString: "1"))
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(1))
                expect(mocks.first!.aString).to(equal("1"))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testAddLast() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.addLast(Mock(aString: "11"))
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(11))
                expect(mocks.last!.aString).to(equal("11"))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testAdd() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.add({ (position, count) in position == 5 }, candidate: Mock(aString: "6_added"))
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(11))
                expect(mocks[5].aString).to(equal("6_added"))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    // MARK: Evict
    func testEvictFirst() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evictFirst()
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(9))
                expect(mocks.first!.aString).to(equal("1"))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictFirstN() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evictFirstN(4)
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(6))
                expect(mocks.first!.aString).to(equal("4"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictFirstExposingCount() {
        var success = false
        checkInitialState()
        addAll(10)
        
        // Do not evict
        actions.evictFirst { count in count > 10 }
            .toObservable()
            .subscribeNext { mocks in
                expect(mocks.count).to(equal(10))
        }.addDisposableTo(DisposeBag())
        
        // Evict
        actions.evictFirst { count in count > 9 }
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(9))
                expect(mocks.first!.aString).to(equal("1"))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictFirstNExposingCount() {
        var success = false
        checkInitialState()
        addAll(10)
        
        // Do not evict
        actions.evictFirstN({ count in count > 10 }, n: 5)
            .toObservable()
            .subscribeNext { mocks in
                expect(mocks.count).to(equal(10))
        }
        
        // Evict
        actions.evictFirstN(
            { count in
                count > 9
            }, n: 5)
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(5))
                expect(mocks[0].aString).to(equal("5"))
                expect(mocks[1].aString).to(equal("6"))
        }
        
        expect(success).toEventually(beTrue())
    }

    func testEvictLast() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evictLast()
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(9))
                expect(mocks.last!.aString).to(equal("8"))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictLastN() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evictLastN(4)
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(6))
                expect(mocks.first!.aString).to(equal("0"))
                expect(mocks.last!.aString).to(equal("5"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictLastExposingCount() {
        var success = false
        checkInitialState()
        addAll(10)
        
        // Do not evict
        actions.evictLast { count in count > 10 }
            .toObservable()
            .subscribeNext { mocks in
                expect(mocks.count).to(equal(10))
        }.addDisposableTo(DisposeBag())
        
        // Evict
        actions.evictLast { count in count > 9 }
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(9))
                expect(mocks.last!.aString).to(equal("8"))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictLastNExposingCount() {
        var success = false
        checkInitialState()
        addAll(10)
        
        // Do not evict
        actions.evictLastN({ count in count > 10 }, n: 5)
            .toObservable()
            .subscribeNext { mocks in
                expect(mocks.count).to(equal(10))
        }
        
        // Evict
        actions.evictLastN({ count in count > 9 }, n: 5)
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(5))
                expect(mocks.first!.aString).to(equal("0"))
                expect(mocks.last!.aString).to(equal("4"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictExposingElementCurrentIteration() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evict { (element: Mock) in element.aString == "3"}
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(9))
                expect(mocks[3].aString).to(equal("4"))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictExposingCountAndPositionAndElementCurrentIteration() {
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
        }.addDisposableTo(DisposeBag())
        
        // Evict
        actions.evict { (position, count, element) in count > 9 && element.aString == "3" }
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(9))
                expect(mocks[3].aString).to(equal("4"))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictIterable() {
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
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictAll() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evictAll()
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(0))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictAllKeepingFirstN() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evictAllKeepingFirstN(3)
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(3))
                expect(mocks[0].aString).to(equal("0"))
                expect(mocks[1].aString).to(equal("1"))
                expect(mocks[2].aString).to(equal("2"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    func testEvictAllKeepingLastN() {
        var success = false
        checkInitialState()
        addAll(10)
        
        actions.evictAllKeepingLastN(7)
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(7))
                expect(mocks[0].aString).to(equal("3"))
                expect(mocks[1].aString).to(equal("4"))
                expect(mocks[2].aString).to(equal("5"))
        }
        
        expect(success).toEventually(beTrue())
    }
    
    // MARK: Update
    func testUpdateExposingElementCurrentIteration() {
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
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testUpdateExposingCountAndPositionAndElementCurrentIteration() {
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
        }.addDisposableTo(DisposeBag())
        
        // Evict
        actions.update({ (position, count, element) in count > 9 && element.aString == "5" }
            , replace: { (element) in Mock(aString: "5_updated") })
            .toObservable()
            .subscribeNext { mocks in
                success = true
                expect(mocks.count).to(equal(10))
                expect(mocks[5].aString).to(equal("5_updated"))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testUpdateIterableExposingElementCurrentIteration() {
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
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    func testUpdateIterableExposingCountAndPositionAndElementCurrentIteration() {
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
        }.addDisposableTo(DisposeBag())
        
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
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    // MARK: - Private methods
    fileprivate func clearCache() -> Observable<[Mock]> {
        let provider = RxProvidersMock.getMocksEvictCache(evict: true)
        return providers.cache(Observable.just([Mock]()), provider: provider)
    }
    
    fileprivate func checkInitialState() {
        var success = false
        
        clearCache().subscribeNext { mocks in
            success = true
            expect(mocks.count).to(equal(0))
        }.addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue())
    }
    
    fileprivate func addAll(_ count: Int) {
        var success = false
        
        var mocks = [Mock]()
        
        for i in 0..<count {
            mocks.append(Mock(aString: "\(i)"))
        }
        
        actions.addAll({ (position, count) in count == 0 } , candidates: mocks)
            .toObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (mocks: [Mock]) in
                success = true
                expect(mocks.count).to(equal(count))
            }).addDisposableTo(DisposeBag())
        
        expect(success).toEventually(beTrue(), timeout: 20, pollInterval: 1, description: nil)
    }
    
}
