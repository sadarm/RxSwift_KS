//
//  Just.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/05/30.
//

import Foundation

extension Observable {
    static func just<Element>(_ element: Element) -> Observable<Element> {
        return Just(element)
    }
}

class Just<Element>: Producer<Element> {
    
    let element: Element
    init(_ element: Element) {
        self.element = element
    }
    
    override func subscribe<Observer>(_ observer: Observer) -> Disposable where Element == Observer.Element, Observer : ObserverType {
        observer.on(.next(self.element))
        observer.on(.completed)
        return Disposables.create()
    }
}
