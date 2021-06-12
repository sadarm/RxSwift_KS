//
//  Take.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/06/09.
//

import Foundation

extension Observable {
    public func take(_ count: Int) -> Observable<Element> {
        return Take(source: self, takeCount: count)
    }
}

private final class Take<Element>: Producer<Element> {
    
    let source: Observable<Element>
    let takeCount: Int
    
    init(source: Observable<Element>, takeCount: Int) {
        self.source = source
        self.takeCount = takeCount
    }
    
}

private class TakeSink<Observer: ObserverType>: ObserverType, Disposable {
    typealias Element = Observer.Element
    
    private let observer: Observer
    private let cancel: Disposable
    private let takeCount: Int
    private var currentCount: Int = 0
    
    private var isDisposed: Bool = false
    
    init(observer: Observer, cancel: Disposable, takeCount: Int) {
        self.observer = observer
        self.cancel = cancel
        self.takeCount = takeCount
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            self.currentCount += 1
            if self.currentCount <= self.takeCount {
                self.observer.on(event)
            } else {
                self.observer.on(.completed)
                self.dispose()
            }
        case .completed, .error:
            self.observer.on(event)
            self.dispose()
        }
    }
    
    func run(_ parent: Take<Element>) -> Disposable {
        return parent.source.subscribe(self)
    }
    
    func dispose() {
        guard !self.isDisposed else { return }
        self.isDisposed = true
    }
}
