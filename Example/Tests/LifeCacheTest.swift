// LifeCacheTest.swift
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

class LifeCacheTest: XCTestCase {

    func testSeconds() {
        var lifeCache = LifeCache(duration: 1, timeUnit: LifeCache.TimeUnit.Seconds)
        let _1Second : Double = 1
        expect(lifeCache.getLifeTimeInSeconds()).to(equal(_1Second))
        
        lifeCache = LifeCache(duration: 21, timeUnit: LifeCache.TimeUnit.Seconds)
        let _21Seconds : Double = 21
        expect(lifeCache.getLifeTimeInSeconds()).to(equal(_21Seconds))
        
        lifeCache = LifeCache(duration: 0, timeUnit: LifeCache.TimeUnit.Seconds)
        let _0Seconds : Double  = 0
        let expected = lifeCache.getLifeTimeInSeconds()
        expect(expected).to(equal(_0Seconds))
    }
    
    func testMinutes() {
        var lifeCache = LifeCache(duration: 1, timeUnit: LifeCache.TimeUnit.Minutes)
        let _1Minute : Double = 60
        expect(lifeCache.getLifeTimeInSeconds()).to(equal(_1Minute))
        
        lifeCache = LifeCache(duration: 21, timeUnit: LifeCache.TimeUnit.Minutes)
        let _21Minutes : Double  = 60 * 21
        expect(lifeCache.getLifeTimeInSeconds()).to(equal(_21Minutes))
        
        lifeCache = LifeCache(duration: 0, timeUnit: LifeCache.TimeUnit.Minutes)
        let _0Minutes : Double  = 0
        let expected = lifeCache.getLifeTimeInSeconds()
        expect(expected).to(equal(_0Minutes))
    }
    
    func testHours() {
        var lifeCache = LifeCache(duration: 1, timeUnit: LifeCache.TimeUnit.Hours)
        let _1Hour : Double  = 60 * 60
        expect(lifeCache.getLifeTimeInSeconds()).to(equal(_1Hour))
        
        lifeCache = LifeCache(duration: 67, timeUnit: LifeCache.TimeUnit.Hours)
        let _67Hours : Double  = 60 * 60 * 67
        expect(lifeCache.getLifeTimeInSeconds()).to(equal(_67Hours))
        
        lifeCache = LifeCache(duration: 0, timeUnit: LifeCache.TimeUnit.Hours)
        let _0Hours : Double  = 0
        let expected = lifeCache.getLifeTimeInSeconds()
        expect(expected).to(equal(_0Hours))
    }
    
    func testDays() {
        var lifeCache = LifeCache(duration: 1, timeUnit: LifeCache.TimeUnit.Days)
        let oneDay : Double  = 60 * 60 * 24
        expect(lifeCache.getLifeTimeInSeconds()).to(equal(oneDay))
        
        lifeCache = LifeCache(duration: 12, timeUnit: LifeCache.TimeUnit.Days)
        let _12Days : Double = 60 * 60 * 24 * 12
        expect(lifeCache.getLifeTimeInSeconds()).to(equal(_12Days))
        
        lifeCache = LifeCache(duration: 0, timeUnit: LifeCache.TimeUnit.Days)
        let _0Days : Double =  0
        let expected = lifeCache.getLifeTimeInSeconds()
        expect(expected).to(equal(_0Days))
    }

}
