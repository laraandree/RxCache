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

import RxCache

public enum RxProvidersMock : Provider {
    case getMock()
    case getMocksWithDetailResponse()
    case getMocksResponseOneSecond()
    case getMocksEvictCache(evict : Bool)
    case getMocksPaginate(page : Int)
    case getMocksPaginateNotExpirable(page : Int)
    case getMocksPaginateEvictAll(page : Int, evictAll: Bool)
    case getMocksPaginateEvictByPage(page : Int, evictByPage: Bool)
    case getMocksFilteredPaginateEvict(filter: String, page : String, evict: EvictProvider)
    case getMocksLogin(Evict: Bool)
    case getEphemeralMocksPaginate(page : String)

    public var lifeCache: LifeCache? {
        switch self {
        case .getMocksResponseOneSecond:
            return LifeCache(duration: 1, timeUnit: LifeCache.TimeUnit.seconds)
        case .getEphemeralMocksPaginate:
            return LifeCache(duration: 0.01, timeUnit: LifeCache.TimeUnit.seconds)
        default:
            return nil
        }
    }
    
    public var dynamicKey: DynamicKey? {
        switch self {
        case let .getMocksPaginate(page):
            return DynamicKey(dynamicKey: String(page))
        case let .getMocksPaginateNotExpirable(page):
            return DynamicKey(dynamicKey: String(page))
        case let .getMocksPaginateEvictAll(page, _):
            return DynamicKey(dynamicKey: String(page))
        case let .getMocksPaginateEvictByPage(page, _):
            return DynamicKey(dynamicKey: String(page))
        case let .getEphemeralMocksPaginate(page):
            return DynamicKey(dynamicKey: String(page))
        default:
            return nil
        }
    }
    
    public var dynamicKeyGroup: DynamicKeyGroup? {
        switch self {
        case let .getMocksFilteredPaginateEvict(filter, page, _):
            return DynamicKeyGroup(dynamicKey: filter, group: page)
        default:
            return nil
        }
    }
    
    public var evict: EvictProvider? {
        switch self {
        case let .getMocksEvictCache(evict):
            return EvictProvider(evict: evict)
        case let .getMocksPaginateEvictAll(_, evict):
            return EvictProvider(evict: evict)
        case let .getMocksLogin(evict):
            return EvictProvider(evict: evict)
        case let .getMocksPaginateEvictByPage(_, evictByPage):
            return EvictDynamicKey(evict: evictByPage)
        case let .getMocksFilteredPaginateEvict(_, _, evict):
            return evict
        default:
            return nil
        }
    }
    
    public func expirable() -> Bool {
        switch self {
        case .getMocksPaginateNotExpirable(_):
            return false
        default:
            return true
        }
    }

}
