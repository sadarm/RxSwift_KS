//
//  FlatMap.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/05/31.
//

import Foundation

extension Observable {
    public static func flatMap<T>(_ map: @escaping (Element) -> Observable<T>) -> Observable<T> {
        return FlatMap(map)
    }
}

private final class FlatMap<S, T>: Producer<T> {
    let map: (S) -> Observable<T>
    init(_ map: @escaping (S) -> Observable<T>) {
        self.map = map
    }
    
    override func run<Observer>(_ observer: Observer, cancel: Disposable) -> (sink: Disposable, subscription: Disposable) where T == Observer.Element, Observer : ObserverType {
        let sink = FlatMapSink(observer: observer, cancel: cancel, map: self.map)
        let subscription = sink.run(self)
        return (sink, subscription)
    }
}

final class FlatMapSink<S, Observer: ObserverType>: ObserverType, Disposable {
    typealias Element = S
    typealias T = Observer.Element
    
    private let observer: Observer
    private let cancel: Disposable
    
    private var isDisposed: Bool = false
    private var isStopped: Bool = false
    
    private let map: (S) -> Observable<T>
    
    init(observer: Observer, cancel: Disposable, map: @escaping (S) -> Observable<T>) {
        self.observer = observer
        self.cancel = cancel
        self.map = map
    }
    
    func on(_ event: Event<Element>) {
        guard !self.isStopped else { return }
        
        switch event {
        case .next(let s):
            let observable = self.map(s)
            let proxy = FlatMapSinkProxy(observer: self.observer)
            observable.subscribe(proxy)
            
            self.observer.on(event)
        case .completed, .error:
            self.isStopped = true
            self.observer.on(event)
            self.dispose()
        }
    }
    
    func run(_ parent: FlatMap<Element>) -> Disposable {
        return parent.mapHandler()
    }
    
    func dispose() {
        guard !self.isDisposed else { return }
        self.isDisposed = true
        self.cancel.dispose()
    }
}

final class FlatMapSinkProxy<Observer: ObserverType>: ObserverType {
    typealias Element = Observer.Element
    
    private let observer: Observer
    
    init(observer: Observer) {
        self.observer = observer
    }
    
    func on(_ event: Event<Element>) {
        self.observer.on(event)
    }
}
