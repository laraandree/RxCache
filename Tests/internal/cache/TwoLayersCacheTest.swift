// TwoLayersCacheTest.swift
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

@testable import RxCache

class TwoLayersCacheTest: XCTestCase {
    private var twoLayersCache : TwoLayersCache!
    private let ProviderKey1 = "ProviderKey1", ProviderKey2 = "ProviderKey2", MockValue = "mock_value"
    private let DynamicKey1 = DynamicKey(dynamicKey: "DynamicKey1") , DynamicKey2 = DynamicKey(dynamicKey: "DynamicKey2")
    private let DummyLifeCache : LifeCache? = nil
    private let DynamicKey1Group1 = DynamicKeyGroup(dynamicKey: "1", group: "1")
    private let DynamicKey1Group2 = DynamicKeyGroup(dynamicKey: "1", group: "2")
    private let DynamicKey2Group1 = DynamicKeyGroup(dynamicKey: "2", group: "1")
    private let DynamicKey2Group2 = DynamicKeyGroup(dynamicKey: "2", group: "2")
    private let mock = [Mock(aString: "mock_value")]
    private let lifeCache = LifeCache(duration: 0.5, timeUnit: LifeCache.TimeUnit.Seconds)
    private let lifeCacheOneSecond = LifeCache(duration: 1, timeUnit: LifeCache.TimeUnit.Seconds)
    private let WaitTime : Double = 0.6
    
    override func setUp() {
        super.setUp()        
        twoLayersCache = TwoLayersCache(persistence: Disk())
        twoLayersCache.evictAll()
    }
    
    override func tearDown() {
        super.tearDown()
        twoLayersCache.evictAll()
    }

    func testWhenSaveAndObjectNotExpiredAndMemoryNotDestroyedRetrieveItFromMemory() {
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        
        let record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil,useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCache)!
        
        expect(record.source.rawValue).to(equal(Source.Memory.rawValue))
        expect(record.cacheables[0].aString).to(equal(MockValue))
    }
    
    func testWhenSaveAndRecordHasNotExpiredAndMemoryDestroyedRetrieveItFromDisk() {
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.mockMemoryDestroyed()
        
        let record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCache)!
        
        expect(record.source.rawValue).to(equal(Source.Persistence.rawValue))
        expect(record.cacheables[0].aString).to(equal(MockValue))
    }
    
    func testWhenSaveAndRecordHasExpiredGetNull() {
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        
        NSThread.sleepForTimeInterval(WaitTime)
        
        let record : Record<Mock>? = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil,useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCache)
        
        expect(record).to(beNil())
    }
    
    func testWhenSaveAndDynamicKeyRecordHasExpiredOnlyGetNullForDynamicKey() {
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)

        NSThread.sleepForTimeInterval(WaitTime)
        
        var recordNil : Record<Mock>? = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil,useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCache)
        expect(recordNil).to(beNil())
        
        recordNil = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil,useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCacheOneSecond)
        expect(recordNil).to(beNil())
        
        let record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCacheOneSecond)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
    }
    
    func testWhenSaveAndDynamicKeyGroupRecordHasExpiredOnlyGetNullForDynamicKeyGroup() {
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group1, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group2, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey2Group1, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey2Group2, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        
        NSThread.sleepForTimeInterval(WaitTime)
        
        var recordNil : Record<Mock>? = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group1,useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCache)
        expect(recordNil).to(beNil())
        
        recordNil = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group1,useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCacheOneSecond)
        expect(recordNil).to(beNil())
        
        var record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group2, useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCacheOneSecond)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
        
        record = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey2Group1, useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCacheOneSecond)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
        
        record = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey2Group2, useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCacheOneSecond)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
    }
    
    func testWhenSaveAndRecordHasNotExpiredDateDoNotGetNull() {
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.mockMemoryDestroyed()

        NSThread.sleepForTimeInterval(WaitTime)
        
        var record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        
        expect(record.source.rawValue).to(equal(Source.Persistence.rawValue))
        expect(record.cacheables[0].aString).to(equal(MockValue))
        
         record = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        
        expect(record.source.rawValue).to(equal(Source.Memory.rawValue))
        expect(record.cacheables[0].aString).to(equal(MockValue))
    }
    
    func testWhenSaveAndEvictGetNull() {
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey2, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)

        twoLayersCache.evictProviderKey(ProviderKey1)
        
        let recordNil : Record<Mock>? = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(recordNil).to(beNil())
        
        let record : Record<Mock> = twoLayersCache.retrieve(ProviderKey2, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        
        expect(record.source.rawValue).to(equal(Source.Memory.rawValue))
        expect(record.cacheables[0].aString).to(equal(MockValue))
    }
    
    func testWhenSaveAndEvictAllGetNull() {
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        
        twoLayersCache.save(ProviderKey2, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey2, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey2, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        
        twoLayersCache.evictAll()
        
        var record : Record<Mock>? = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(record).to(beNil())
        
        record = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(record).to(beNil())
        
        record = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(record).to(beNil())
        
        record = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(record).to(beNil())
        
        record = twoLayersCache.retrieve(ProviderKey2, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(record).to(beNil())
        
        record = twoLayersCache.retrieve(ProviderKey2, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(record).to(beNil())
        
        record = twoLayersCache.retrieve(ProviderKey2, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(record).to(beNil())
    }
    
    func testWhenSaveAndNotEvictDynamicKeysGetAll() {
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey2, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey2, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        
        var record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
        
        record = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
        
        record = twoLayersCache.retrieve(ProviderKey2, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
        
        record = twoLayersCache.retrieve(ProviderKey2, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
    }
    
    func testWhenSaveDynamicKeyAndReSaveDynamicKeyGetLastValue() {
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, cacheables: [Mock(aString: "new_value")], lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        
        let record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        expect(record.cacheables[0].aString).to(equal("new_value"))
    }
    
    func testWhenSaveAndEvictDynamicKeysGetAllNull() {
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
    
        var record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
        
        record = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
        
        twoLayersCache.evictProviderKey(ProviderKey1)
        
        var recordNil : Record<Mock>? = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(recordNil).to(beNil())
        
        recordNil = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(recordNil).to(beNil())        
    }
    
    func testWhenSaveAndEvictOneDynamicKeyGetOthers() {
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey1, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey2, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)

        twoLayersCache.evictDynamicKey(ProviderKey1, dynamicKey: DynamicKey1)
        
        let recordNil : Record<Mock>? = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(recordNil).to(beNil())
        
        var record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: DynamicKey2, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
        
         record = twoLayersCache.retrieve(ProviderKey2, dynamicKey: DynamicKey1, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
    }
    
    func testWhenSaveAndEvictOneDynamicKeyGroupGetOthers() {
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group1, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group2, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        
        twoLayersCache.evictDynamicKeyGroup(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group1)
        
        let recordNil : Record<Mock>? = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group1, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)
        expect(recordNil).to(beNil())
        
        let record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group2, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
    }
    
    func testWhenExpirationDateHasBeenModifiedThenReflectThisChange() {
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        NSThread.sleepForTimeInterval(WaitTime)

        var record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCacheOneSecond)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
        
        var recordNil : Record<Mock>? = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCache)
        expect(recordNil).to(beNil())
        
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        NSThread.sleepForTimeInterval(WaitTime)

        record = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCacheOneSecond)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
    
        recordNil = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCache)
        expect(recordNil).to(beNil())
        
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        NSThread.sleepForTimeInterval(WaitTime)

        record = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: nil)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
    }
    
    func testWhenExpiredDateAndNotuseExpiredDataIfLoaderNotAvailableThenGetNull() {
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        NSThread.sleepForTimeInterval(WaitTime)
        
        let recordNil : Record<Mock>? = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: false, lifeCache: lifeCache)
        expect(recordNil).to(beNil())
    }
    
    func testWhenExpiredDateButuseExpiredDataIfLoaderNotAvailableThenGetMock() {
        twoLayersCache.save(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, cacheables: mock, lifeCache: DummyLifeCache, maxMBPersistenceCache: RxCache.Providers.maxMBPersistenceCache, isExpirable: true)
        NSThread.sleepForTimeInterval(WaitTime)
        
        let record : Record<Mock> = twoLayersCache.retrieve(ProviderKey1, dynamicKey: nil, dynamicKeyGroup: nil, useExpiredDataIfLoaderNotAvailable: true, lifeCache: lifeCache)!
        expect(record.cacheables[0].aString).to(equal(MockValue))
    }
}
