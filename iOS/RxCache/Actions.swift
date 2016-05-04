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
    
    // MARK: - Add
    /**
    *
    * @param exchange2
    * @param candidate the element to add
    * @return the instance itself to keep chain
    */
    func add(func2: Func2, candidate: T) -> Actions<T> {
        return addAll(func2, candidates: [candidate])
    }
    
    /**
     * Add the object at the first position of the cache.
     * @param element the object to add to the cache.
     * @return itself
     */
    func addFirst(candidate: T) -> Actions<T> {
        return addAll({ (position, count)in position == 0 }, candidates: [candidate])
    }
    
    /**
     * Add the object at the last position of the cache.
     * @param element the object to add to the cache.
     * @return itself
     */
    func addLast(candidate: T) -> Actions<T> {
        return addAll({ (position, count)in position == count }, candidates: [candidate])
    }
    
    /**
     * Func2 will be called for every iteration until its condition returns true.
     * When true, the elements are added to the cache at the position of the current iteration.
     * @param func2 exposes the position of the current iteration and the count of elements in the cache.
     * @param elements the objects to add to the cache.
     * @return itself
     */
    func addAll(func2: Func2, candidates: [T]) -> Actions<T> {
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
    
    // MARK: - Actions
    
    // MARK: - Evict
    /**
    * Evict object at the first position of the cache
    * @return itself
    */
    func evictFirst() -> Actions<T> {
        return evict { (position, count, element) in position == 0 }
    }
    
    /**
     * Evict object at the last position of the cache.
     * @return itself
     */
    func evictLast() -> Actions<T> {
        return evict { (position, count, element) in position == count - 1 }
    }
    
    /**
     * Evict object at the first position of the cache.
     * @param func1Count exposes the count of elements in the cache.
     * @return itself
     */
    func evictFirst(func1Count: Func1Count) -> Actions<T> {
        return evict { (position, count, element) in position == 0 && func1Count(count: count) }
    }
    
    /**
     * Evict object at the last position of the cache.
     * @param func1Count exposes the count of elements in the cache.
     * @return itself
     */
    func evictLast(func1Count: Func1Count) -> Actions<T> {
        return evict { (position, count, element) in position == count - 1 && func1Count(count: count) }
    }
    
    /**
     * Func1Element will be called for every iteration until its condition returns true.
     * When true, the element of the current iteration is evicted from the cache.
     * @param func1Element exposes the element of the current iteration.
     * @return itself
     */
    func evict(func1Element: Func1Element) -> Actions<T> {
        return evict { (position, count, element) in func1Element(element: element) }
    }
    
    /**
     * Func3 will be called for every iteration until its condition returns true.
     * When true, the element of the current iteration is evicted from the cache.
     * @param func3 exposes the position of the current iteration, the count of elements in the cache and the element of the current iteration.
     * @return itself
     */
    func evict(func3: Func3) -> Actions<T> {
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
    func evictAll() -> Actions<T> {
        let func3 = { (position: Int, count: Int, element: T) in true }
        return evictIterable(func3)
    }
    
    /**
     * Func3 will be called for every iteration.
     * When true, the element of the current iteration is evicted from the cache.
     * @param func3 exposes the position of the current iteration, the count of elements in the cache and the element of the current iteration.
     * @return itself
     */
    func evictIterable(func3: Func3) -> Actions<T> {
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
    func update(func1Element: Func1Element, replace: Replace) -> Actions<T> {
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
    func update(func3: Func3, replace: Replace) -> Actions<T> {
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
    func updateIterable(func1Element: Func1Element, replace: Replace) -> Actions<T> {
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
    func updateIterable(func3: Func3, replace: Replace) -> Actions<T> {
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
    func toObservable() -> Observable<[T]> {
        return cache.flatMap { elements in self.evict(elements: elements) }
    }
}
