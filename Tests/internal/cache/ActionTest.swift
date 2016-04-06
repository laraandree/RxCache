// ActionTest.swift
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

@testable import RxCache

class Actiontest : XCTestCase {
    var actionUT : ActionUT!
    
    let ProviderKey = "get_mocks"
    let DynamicKey1 = DynamicKey(dynamicKey: "filter_1")
    let DynamicKey2 = DynamicKey(dynamicKey: "filter_2")
    let DynamicKey1Group1 = DynamicKeyGroup(dynamicKey: "filter_1", group: "page_1")
    let DynamicKey1Group2 = DynamicKeyGroup(dynamicKey: "filter_1", group: "page_2")
    let DynamicKey2Group1 = DynamicKeyGroup(dynamicKey: "filter_2", group: "page_1")
    let DynamicKey2Group2 = DynamicKeyGroup(dynamicKey: "filter_2", group: "page_2")
    
    var filter1Page1, filter1Page2, filter2Page1, filter2Page2 : String!

    override func setUp() {
        super.setUp()
        actionUT = ActionUT()
        
        filter1Page1 = actionUT.composeKey(ProviderKey, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group1)
        actionUT.memory.put(filter1Page1, record: mock(filter1Page1))
        
        filter1Page2 = actionUT.composeKey(ProviderKey, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group2)
        actionUT.memory.put(filter1Page2, record: mock(filter1Page2))
        
        filter2Page1 = actionUT.composeKey(ProviderKey, dynamicKey: nil, dynamicKeyGroup: DynamicKey2Group1)
        actionUT.memory.put(filter2Page1, record: mock(filter2Page1))
        
        filter2Page2 = actionUT.composeKey(ProviderKey, dynamicKey: nil, dynamicKeyGroup: DynamicKey2Group2)
        actionUT.memory.put(filter2Page2, record: mock(filter2Page2))
    }
    
    func testCheckKeysMatchingProviderKey() {
        let keysMatchingProviderKey = actionUT.getKeysMatchingProviderKey(ProviderKey)
        expect(keysMatchingProviderKey[0]).to(equal(filter1Page1))
        expect(keysMatchingProviderKey[1]).to(equal(filter1Page2))
        expect(keysMatchingProviderKey[2]).to(equal(filter2Page1))
        expect(keysMatchingProviderKey[3]).to(equal(filter2Page2))
        expect(keysMatchingProviderKey.count).to(equal(4))
    }
    
    func testCheckKeysMatchingDynamicKey() {
        let keysMatchingDynamicKey1 = actionUT.getKeysMatchingDynamicKey(ProviderKey, dynamicKey: DynamicKey1)
        expect(keysMatchingDynamicKey1[0]).to(equal(filter1Page1))
        expect(keysMatchingDynamicKey1[1]).to(equal(filter1Page2))
        expect(keysMatchingDynamicKey1.count).to(equal(2))

        let keysMatchingDynamicKey2 = actionUT.getKeysMatchingDynamicKey(ProviderKey, dynamicKey: DynamicKey2)
        expect(keysMatchingDynamicKey2[0]).to(equal(filter2Page1))
        expect(keysMatchingDynamicKey2[1]).to(equal(filter2Page2))
        expect(keysMatchingDynamicKey2.count).to(equal(2))
    }
    
    func testCheckKeysMatchingDynamicKeyGroup() {
        let keyMatchingDynamicKey1DynamicKeyGroup1 = actionUT.getKeyMatchingDynamicKeyGroup(ProviderKey, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group1)
        expect(keyMatchingDynamicKey1DynamicKeyGroup1).to(equal(filter1Page1))
        
        let keyMatchingDynamicKey1DynamicKeyGroup2 = actionUT.getKeyMatchingDynamicKeyGroup(ProviderKey, dynamicKey: nil, dynamicKeyGroup: DynamicKey1Group2)
        expect(keyMatchingDynamicKey1DynamicKeyGroup2).to(equal(filter1Page2))
        
        let keyMatchingDynamicKey2DynamicKeyGroup1 = actionUT.getKeyMatchingDynamicKeyGroup(ProviderKey, dynamicKey: nil, dynamicKeyGroup: DynamicKey2Group1)
        expect(keyMatchingDynamicKey2DynamicKeyGroup1).to(equal(filter2Page1))
        
        let keyMatchingDynamicKey2DynamicKeyGroup2 = actionUT.getKeyMatchingDynamicKeyGroup(ProviderKey, dynamicKey: nil, dynamicKeyGroup: DynamicKey2Group2)
        expect(keyMatchingDynamicKey2DynamicKeyGroup2).to(equal(filter2Page2))
    }
    
    
    func mock(value : String) -> Record<Mock> {
        return Record<Mock>(cacheables: [Mock(aString: value)], lifeTimeInSeconds: 0, isExpirable: true)
    }
    
}

class ActionUT : Action {
    let memory : Memory
    
    init() {
        memory = MemoryMock()
    }
}

class MemoryMock : Memory {
    private var records = [String]()
    
    func getIfPresent<T>(key: String) -> Record<T>? {
        var data = ""
        
        records.forEach { (value) -> () in
            if value == key {
                data = value
            }
        }
        
        return Record<T>(cacheables: [data as! T], lifeTimeInSeconds: 0, isExpirable: true)
    }
    
    func put<T>(key: String, record: Record<T>) {
        records.append(key)
    }
    
    func keys() -> [String] {
        return records
    }
    
    func evict(key: String) {
        fatalError("evict mock not implemented")
    }
    
    func evictAll() {
        fatalError("evictAll mock not implemented")
    }
}

