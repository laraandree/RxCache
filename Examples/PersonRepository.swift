// PersonRepository.swift
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
import RxSwift

class PersonRespository {
    private let rxCache: RxCache
    
    init() {
        rxCache = RxCache.Providers
    }
    
    func getPersons() -> Observable<[Person]> {
        let provider: Provider = CacheProviders.GlossStruct
        return rxCache.cache(getPersonsFromAPI(), provider: provider)
    }
    
    private func getPersonsFromAPI() -> Observable<[Person]> {
        let victorJSON = ["name":"Víctor", "favouriteIntNumber":28]
        let ivanJSON = ["name":"Iván"]
        if let victor = Person(json: victorJSON), ivan = Person(json: ivanJSON) {
            return Observable.just([victor, ivan])
        }
        return Observable.error(NSError(domain: "", code: -1, userInfo: nil))
    }

}