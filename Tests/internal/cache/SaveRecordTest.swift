// SaveRecordTest.swift
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

import Foundation
import XCTest
import Nimble
import RxSwift

@testable import RxCache

class SaveRecordTest : XCTestCase {
    fileprivate var saveRecordUT : SaveRecord!
    fileprivate var twoLayersCache : TwoLayersCache!
    fileprivate var persistence : Disk!
    
    override func setUp() {
        super.setUp()
        
        persistence = Disk()
        
        twoLayersCache = TwoLayersCache(persistence: persistence)
        twoLayersCache.evictAll()
        
        saveRecordUT = SaveRecord(memory: MemoryNsCache(), persistence : persistence)
    }
    
    override func tearDown() {
        super.tearDown()
        twoLayersCache.evictAll()
    }
    
    func testWhenMaxPersistenceExceed10MBDoNotPersistsData() {
        whenMaxPersistenceExceedDoNotPersistsData(5)
    }
    
    func testWhenMaxPersistenceExceed20MBDoNotPersistsData() {
        whenMaxPersistenceExceedDoNotPersistsData(10)
    }
    
    func testWhenMaxPersistenceExceed30MBDoNotPersistsData() {
        whenMaxPersistenceExceedDoNotPersistsData(15)
    }
    
    func whenMaxPersistenceExceedDoNotPersistsData(_ maxMB: Int) {
        XCTAssert(persistence.storedMB() == 0)
        expect(self.saveRecordUT.memory.keys().count).to(equal(0))

        let records = 100
        
        //24 megabytes of memory
        for i in 1...records {
            saveRecordUT.save(String(i), dynamicKey: nil, dynamicKeyGroup: nil, cacheables: createMocks(records), lifeCache: nil, maxMBPersistenceCache: maxMB, isExpirable: true)
        }
        
        let expected = Double(maxMB) * 0.85
        let storedMB = Double(self.persistence.storedMB()!)
        expect(storedMB).toEventually(beCloseTo(expected, within: 2.0), timeout: 5)
        expect(self.saveRecordUT.memory.keys().count).to(equal(records))
    }
    
    
    //39 megabytes of memory
    fileprivate func createMocks(_ size : Int) -> [Mock] {
        var mocks = [Mock]()
        
        for _ in 1...size {
            mocks.append(Mock(aString: "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC."+"Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC."+"Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC."+"Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC," +
                "making it over 2000 years old.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, " +
                "making it over 2000 years old. Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC."))
        }
        
        return mocks
    }
}
