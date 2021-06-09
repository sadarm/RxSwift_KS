//
//  Skip.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/06/09.
//

import Foundation

extension Observable {
    public func skip(_ count: Int) -> Observable<Element> {
        return Skip(source: self, skipCount: count)
    }
}

private final class Skip<Element>: Producer<Element> {
    let source: Observable<Element>
    let skipCount: Int
    
    init(source: Observable<Element>, skipCount: Int) {
        self.source = source
        self.skipCount = skipCount
    }
    
    override func run<Observer>(_ observer: Observer, cancel: Disposable) -> (sink: Disposable, subscription: Disposable) where Element == Observer.Element, Observer : ObserverType {
        let sink = SkipSink(observer: observer, cancel: cancel, skipCount: self.skipCount)
        let subscription = sink.run(self)
        return (sink, subscription)
    }
}

private final class SkipSink<Observer: ObserverType>: ObserverType, Disposable {
    typealias Element = Observer.Element
    
    private let observer: Observer
    private let cancel: Disposable
    
    private var isDisposed: Bool = false
    private var isStopped: Bool = false
    
    private let skipCount: Int
    
    private var currentCount: Int = 0
    
    init(observer: Observer, cancel: Disposable, skipCount: Int) {
        self.observer = observer
        self.cancel = cancel
        self.skipCount = skipCount
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            self.currentCount += 1
            if self.currentCount > self.skipCount {
                self.observer.on(event)
            }
        case .completed, .error:
            self.isStopped = true
            self.observer.on(event)
        }
    }
    
    func run(_ parent: Skip<Element>) -> Disposable {
        return parent.source.subscribe(self)
    }
    
    func dispose() {
        guard !self.isDisposed else { return }
        self.isDisposed = true
        self.cancel.dispose()
    }
}
