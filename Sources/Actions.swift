//
//  Actions.swift
//  RxCache
//
//  Created by Roberto Frontado on 4/15/16.
//  Copyright © 2016 Roberto Frontado. All rights reserved.
//

import RxSwift

public class Actions<T> {
    
    public typealias Evict = (elements: [T]) -> Observable<[T]>
    public typealias Func1Count = (count: Int) -> Bool
    public typealias Func1Element = (element: T) -> Bool
    public typealias Func2 = (position: Int, count: Int) -> Bool
    public typealias Func3 = (position: Int, count: Int, element: T) -> Bool
    public typealias Replace = (element: T) -> T
    
    private var cache: Observable<[T]>
    private let evict: Evict
    
    private init(cache: Observable<[T]>, evict: Evict) {
        self.cache = cache
        self.evict = evict
    }
    
    public static func with<T>(provider: Provider) -> Actions<T> {
        let cacheProvider = PlaceholderCacheProvider(provider: provider)
        let oCache = RxCache.Providers.cache(RxCache.errorObservable([T].self), provider: cacheProvider)
        
        let evictProvider = PlaceholderEvictProvider(provider: provider)
        let evictBlock = { (elements: [T]) -> Observable<[T]> in
            return RxCache.Providers.cache(Observable.just(elements), provider: evictProvider)
        }
        
        return Actions<T>(cache: oCache, evict: evictBlock)
    }
    
    // MARK: - Actions
    
    // MARK: - Add
    /**
    *
    * @param exchange2
    * @param candidate the element to add
    * @return the instance itself to keep chain
    */
    public func add(func2: Func2, candidate: T) -> Actions<T> {
        return addAll(func2, candidates: [candidate])
    }
    
    /**
     * Add the object at the first position of the cache.
     * @param element the object to add to the cache.
     * @return itself
     */
    public func addFirst(candidate: T) -> Actions<T> {
        return addAll({ (position, count)in position == 0 }, candidates: [candidate])
    }
    
    /**
     * Add the object at the last position of the cache.
     * @param element the object to add to the cache.
     * @return itself
     */
    public func addLast(candidate: T) -> Actions<T> {
        return addAll({ (position, count)in position == count }, candidates: [candidate])
    }
    
    /**
     * Add the objects at the first position of the cache.
     * @param elements the objects to add to the cache.
     * @return itself
     */
    public func addAllFirst(elements: [T]) -> Actions<T> {
        return addAll({ (position, count) in position == 0 }, candidates: elements)
    }
    
    /**
     * Add the objects at the last position of the cache.
     * @param elements the objects to add to the cache.
     * @return itself
     */
    public func addAllLast(elements: [T]) -> Actions<T> {
        return addAll({ (position, count) in position == count }, candidates: elements)
    }
    
    /**
     * Func2 will be called for every iteration until its condition returns true.
     * When true, the elements are added to the cache at the position of the current iteration.
     * @param func2 exposes the position of the current iteration and the count of elements in the cache.
     * @param elements the objects to add to the cache.
     * @return itself
     */
    public func addAll(func2: Func2, candidates: [T]) -> Actions<T> {
        cache = cache.map { (var elements) in
            let count = elements.count
            for var position = 0; position <= count; position++ {
                if func2(position: position, count: count) {
                    elements.insertContentsOf(candidates, at: position)
                    break
                }
            }
            return elements
        }
        return self
    }
    
    // MARK: - Evict
    /**
    * Evict object at the first position of the cache
    * @return itself
    */
    public func evictFirst() -> Actions<T> {
        return evict { (position, count, element) in position == 0 }
    }
    
    /**
    * Evict as much objects as requested by n param starting from the first position.
    * @param n the amount of elements to evict.
    * @return itself
    */
    public func evictFirstN(n: Int) -> Actions<T> {
        return evictFirstN({ count in true }, n: n)
    }
    
    /**
    * Evict object at the last position of the cache.
    * @return itself
    */
    public func evictLast() -> Actions<T> {
        return evict { (position, count, element) in position == count - 1 }
    }
    
    /**
    * Evict as much objects as requested by n param starting from the last position.
    * @param n the amount of elements to evict.
    * @return itself
    */
    public func evictLastN(n: Int) -> Actions<T> {
        return evictLastN({ count in true }, n: n)
    }
    
    /**
     * Evict object at the first position of the cache.
     * @param func1Count exposes the count of elements in the cache.
     * @return itself
     */
    public func evictFirst(func1Count: Func1Count) -> Actions<T> {
        return evict { (position, count, element) in position == 0 && func1Count(count: count) }
    }
    
    /**
     * Evict as much objects as requested by n param starting from the first position.
     * @param func1Count exposes the count of elements in the cache.
     * @param n the amount of elements to evict.
     * @return itself
     */
    public func evictFirstN(func1Count: Func1Count, n: Int) -> Actions<T> {
        return evictIterable { (position, count, element) in position < n && func1Count(count: count) }
    }
    
    /**
     * Evict object at the last position of the cache.
     * @param func1Count exposes the count of elements in the cache.
     * @return itself
     */
    public func evictLast(func1Count: Func1Count) -> Actions<T> {
        return evict { (position, count, element) in position == count - 1 && func1Count(count: count) }
    }
    
    /**
    * Evict as much objects as requested by n param starting from the last position.
    * @param func1Count exposes the count of elements in the cache.
    * @param n the amount of elements to evict.
    * @return itself
    */
    public func evictLastN(func1Count: Func1Count, n: Int) -> Actions<T> {
        return evictIterable({ (position, count, element) in count - position <= n && func1Count(count: count)
        })
    }
     
    /**
     * Func1Element will be called for every iteration until its condition returns true.
     * When true, the element of the current iteration is evicted from the cache.
     * @param func1Element exposes the element of the current iteration.
     * @return itself
     */
    public func evict(func1Element: Func1Element) -> Actions<T> {
        return evict { (position, count, element) in func1Element(element: element) }
    }
    
    /**
     * Func3 will be called for every iteration until its condition returns true.
     * When true, the element of the current iteration is evicted from the cache.
     * @param func3 exposes the position of the current iteration, the count of elements in the cache and the element of the current iteration.
     * @return itself
     */
    public func evict(func3: Func3) -> Actions<T> {
        cache = cache.map { (var elements) in
            let count = elements.count
            for position in 0..<count {
                if func3(position: position, count: count, element: elements[position]) {
                    elements.removeAtIndex(position)
                    break
                }
            }
            return elements
        }
        return self
    }
    
    /**
     * Evict all elements from the cache
     * @return itself
     */
    public func evictAll() -> Actions<T> {
        return evictIterable { (position, count, element) in true }
    }
    
    /**
    * Evict elements from the cache starting from the first position until its count is equal to the value specified in n param.
    * @param n the amount of elements to keep from evict.
    * @return itself
    */
    public func evictAllKeepingFirstN(n: Int) -> Actions<T> {
        return evictIterable { (position, count, element) in
            let positionToStartEvicting = count - (count - n)
            return position >= positionToStartEvicting
        }
    }
    
    /**
    * Evict elements from the cache starting from the last position until its count is equal to the value specified in n param.
    * @param n the amount of elements to keep from evict.
    * @return itself
    */
    public func evictAllKeepingLastN(n: Int) -> Actions<T> {
        return evictIterable { (position, count, element) in
            let elementsToEvict = count - n
            return position < elementsToEvict
        }
    }
    
    /**
     * Func3 will be called for every iteration.
     * When true, the element of the current iteration is evicted from the cache.
     * @param func3 exposes the position of the current iteration, the count of elements in the cache and the element of the current iteration.
     * @return itself
     */
    public func evictIterable(func3: Func3) -> Actions<T> {
        cache = cache.map { (var elements) in
            let count = elements.count
            // Inverse for
            for var position = count - 1; position >= 0; position-- {
                if func3(position: position, count: count, element: elements[position]) {
                    elements.removeAtIndex(position)
                }
            }
            return elements
        }
        return self
    }
    
    // MARK: - Update
    /**
    * Func1Element will be called for every iteration until its condition returns true.
    * When true, the element of the current iteration is updated.
    * @param func1Element exposes the element of the current iteration.
    * @param replace exposes the original element and expects back the one modified.
    * @return itself
    */
    public func update(func1Element: Func1Element, replace: Replace) -> Actions<T> {
        return update({ (position, count, element) in func1Element(element: element) }
            , replace: { element in replace(element: element) })
    }
    
    /**
     * Func3 will be called for every iteration until its condition returns true.
     * When true, the element of the current iteration is updated.
     * @param func3 exposes the position of the current iteration, the count of elements in the cache and the element of the current iteration.
     * @param replace exposes the original element and expects back the one modified.
     * @return itself
     */
    public func update(func3: Func3, replace: Replace) -> Actions<T> {
        cache = cache.map { (var elements) in
            let count = elements.count
            for position in 0..<count {
                if func3(position: position, count: count, element: elements[position]) {
                    elements[position] = replace(element: elements[position])
                    break
                }
            }
            return elements
        }
        return self
    }
    
    /**
     * Func1Element will be called for every.
     * When true, the element of the current iteration is updated.
     * @param func1Element exposes the element of the current iteration.
     * @param replace exposes the original element and expects back the one modified.
     * @return itself
     */
    public func updateIterable(func1Element: Func1Element, replace: Replace) -> Actions<T> {
        return updateIterable({ (position, count, element) in func1Element(element: element)
            }, replace: { element in replace(element: element) })
    }
    
    /**
     * Func3 will be called for every iteration.
     * When true, the element of the current iteration is updated.
     * @param func3 exposes the position of the current iteration, the count of elements in the cache and the element of the current iteration.
     * @param replace exposes the original element and expects back the one modified.
     * @return itself
     */
    public func updateIterable(func3: Func3, replace: Replace) -> Actions<T> {
        cache = cache.map { (var elements) in
            let count = elements.count
            for position in 0..<count {
                if func3(position: position, count: count, element: elements[position]) {
                    elements[position] = replace(element: elements[position])
                }
            }
            return elements
        }
        return self
    }
    
    // MARK: - To Observable
    public func toObservable() -> Observable<[T]> {
        return cache.flatMap { elements in self.evict(elements: elements) }
    }
}
