//
//  GetDeepCopy.swift
//  RxCache
//
//  Created by Roberto Frontado on 4/15/16.
//  Copyright © 2016 victoralbertos. All rights reserved.
//

class GetDeepCopy {
    
    func getDeepCopy<T>(objects: [T]) -> [T] {
        
        // Validates that T is a Class, not a Struct
        if !(T.self is AnyClass) {
            return objects
        }
        
        return objects.map { (object) -> T in
            if let cacheable = T.self as? Cacheable.Type,
                let data = object as? Cacheable,
                let json = data.toJSON() {
                return cacheable.init(json: json) as! T
            }
//            if let gloss = T.self as? GlossCacheable.Type,
//                let data = object as? GlossCacheable,
//                let json = data.toJSON() {
//                    return gloss.init(json: json) as! T
//            } else if let objectMapper = T.self as? OMCacheable.Type,
//                    let data = object as? OMCacheable {
//                    return objectMapper.init(JSON: data.toJSON()) as! T
//            }
            else {
                fatalError((String(describing: T.self) + Locale.CacheableIsNotEnought))
            }
        }
    }
}
