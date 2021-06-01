//
//  Producer.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/05/30.
//

import Foundation

class Producer<Element>: Observable<Element> {

    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Element == Observer.Element {
        let disposable = ProducerDisposable()
        let sinkAndSubscription = self.run(observer, cancel: disposable)
        disposable.setSink(sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)
        return disposable
    }
    
    func run<Observer: ObserverType>(_ observer: Observer, cancel: Disposable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        fatalError("not implemented")
    }
}

private final class ProducerDisposable: Disposable {
    var sink: Disposable?
    var subscription: Disposable?
    
    var isDisposed: Bool = false
    
    init() {
        
    }
    
    func setSink(_ sink: Disposable, subscription: Disposable) {
        self.sink = sink
        self.subscription = subscription
        
        if self.isDisposed {
            sink.dispose()
            subscription.dispose()
            self.sink = nil
            self.subscription = nil
        }
    }
    
    func dispose() {
        guard !self.isDisposed else { return }
        
        self.isDisposed = true
        self.sink?.dispose()
        self.subscription?.dispose()
        self.sink = nil
        self.subscription = nil
    }
}
