//
//  AnonymousObservable.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/05/30.
//

import Foundation

extension Observable {
    public static func create(_ subscribe: @escaping (AnyObserver<Element>) -> Disposable) -> Observable<Element> {
        return AnonymousObservable(subscribe)
    }
}

final class AnonymousObservable<Element>: Producer<Element> {
    typealias SubscribeHandler = (AnyObserver<Element>) -> Disposable
    let subscribeHandler: SubscribeHandler
    
    init(_ subscribeHandler: @escaping SubscribeHandler) {
        self.subscribeHandler = subscribeHandler
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Disposable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
        let subscription = sink.run(self)
        return (sink, subscription)
    }
    
}

final class AnonymousObservableSink<Observer: ObserverType>: ObserverType, Disposable {
    typealias Element = Observer.Element
    
    private let observer: Observer
    private let cancel: Disposable
    
    private var isDisposed: Bool = false
    private var isStopped: Bool = false
    
    init(observer: Observer, cancel: Disposable) {
        self.observer = observer
        self.cancel = cancel
    }
    
    func on(_ event: Event<Element>) {
        guard !self.isStopped else { return }
        
        switch event {
        case .next:
            self.observer.on(event)
        case .completed, .error:
            self.isStopped = true
            self.observer.on(event)
            self.dispose()
        }
    }
    
    func run(_ parent: AnonymousObservable<Element>) -> Disposable {
        return parent.subscribeHandler(AnyObserver(self))
    }
    
    func dispose() {
        guard !self.isDisposed else { return }
        self.isDisposed = true
        self.cancel.dispose()
    }
}


