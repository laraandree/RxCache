// RxProvidersMock.swift
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
import RxCache

public enum RxProvidersMock : Provider {
    case GetMock()
    case GetMocksWithDetailResponse()
    case GetMocksResponseOneSecond()
    case GetMocksEvictCache(evict : Bool)
    case GetMocksPaginate(page : Int)
    case GetMocksPaginateNotExpirable(page : Int)
    case GetMocksPaginateEvictAll(page : Int, evictAll: Bool)
    case GetMocksPaginateEvictByPage(page : Int, evictByPage: Bool)
    case GetMocksFilteredPaginateEvict(filter: String, page : String, evict: EvictProvider)
    case GetMocksLogin(Evict: Bool)
    case GetEphemeralMocksPaginate(page : String)

    public var lifeCache: LifeCache? {
        switch self {
        case GetMocksResponseOneSecond:
            return LifeCache(duration: 1, timeUnit: LifeCache.TimeUnit.Seconds)
        case GetEphemeralMocksPaginate:
            return LifeCache(duration: 0.01, timeUnit: LifeCache.TimeUnit.Seconds)
        default:
            return nil
        }
    }
    
    public var dynamicKey: DynamicKey? {
        switch self {
        case let GetMocksPaginate(page):
            return DynamicKey(dynamicKey: String(page))
        case let GetMocksPaginateNotExpirable(page):
            return DynamicKey(dynamicKey: String(page))
        case let GetMocksPaginateEvictAll(page, _):
            return DynamicKey(dynamicKey: String(page))
        case let GetMocksPaginateEvictByPage(page, _):
            return DynamicKey(dynamicKey: String(page))
        case let GetEphemeralMocksPaginate(page):
            return DynamicKey(dynamicKey: String(page))
        default:
            return nil
        }
    }
    
    public var dynamicKeyGroup: DynamicKeyGroup? {
        switch self {
        case let GetMocksFilteredPaginateEvict(filter, page, _):
            return DynamicKeyGroup(dynamicKey: filter, group: page)
        default:
            return nil
        }
    }
    
    public var evict: EvictProvider? {
        switch self {
        case let GetMocksEvictCache(evict):
            return EvictProvider(evict: evict)
        case let GetMocksPaginateEvictAll(_, evict):
            return EvictProvider(evict: evict)
        case let GetMocksLogin(evict):
            return EvictProvider(evict: evict)
        case let GetMocksPaginateEvictByPage(_, evictByPage):
            return EvictDynamicKey(evict: evictByPage)
        case let GetMocksFilteredPaginateEvict(_, _, evict):
            return evict
        default:
            return nil
        }
    }
    
    public func expirable() -> Bool {
        switch self {
        case GetMocksPaginateNotExpirable(_):
            return false
        default:
            return true
        }
    }

}