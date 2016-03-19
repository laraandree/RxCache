// ViewController.swift
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

import RxSwift

class ViewController: UIViewController {
    
    
    private let personRepository = PersonRespository()
    private let dogRepository = DogRespository()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPersons()
        loadDogs()
    }
    
    private func loadPersons() {
        personRepository.getPersonsEvict(false).subscribeNext { persons in
            _ = persons.map { print($0) }
        }.addDisposableTo(disposeBag)
    }
    
    private func loadDogs() {
        dogRepository.getDogs().subscribeNext { dogs in
            _ = dogs.map { print($0) }
            }.addDisposableTo(disposeBag)
    }
    
    @IBAction func loadFreshPersons(sender: UIButton) {
        personRepository.getPersonsEvict(false).subscribeNext { persons in
            _ = persons.map { print($0) }
            }.addDisposableTo(disposeBag)
    }

    @IBAction func addPerson(sender: UIButton) {
        let randomPersonJSON = ["name":"John", "favouriteIntNumber":17]
        if let person = Person(json: randomPersonJSON) {
            personRepository.addPerson(person).subscribeNext { person in
                print("Added \(person.name)")
            }.addDisposableTo(disposeBag)
        }
    }
}

