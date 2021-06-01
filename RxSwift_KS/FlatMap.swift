//
//  FlatMap.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/05/31.
//

import Foundation

extension Observable {
    public func flatMap<DestinationElement>(_ map: @escaping (Element) -> Observable<DestinationElement>) -> Observable<DestinationElement> {
        return FlatMap(source: self, map: map)
    }
}

private final class FlatMap<SourceElement, DestinationElement>: Producer<DestinationElement> {
    private let source: Observable<SourceElement>
    private let map: (SourceElement) -> Observable<DestinationElement>
    
    init(source: Observable<SourceElement>, map: @escaping (SourceElement) -> Observable<DestinationElement>) {
        self.source = source
        self.map = map
    }
    
    override func run<Observer>(_ observer: Observer, cancel: Disposable) -> (sink: Disposable, subscription: Disposable) where DestinationElement == Observer.Element, Observer : ObserverType {
        let sink = FlatMapSink(observer: observer, cancel: cancel, map: self.map)
        let subscription = sink.run(self.source)
        return (sink, subscription)
    }
}

final class FlatMapSink<SourceElement, Observer: ObserverType>: ObserverType, Disposable {
    typealias Element = SourceElement
    typealias DestinationElement = Observer.Element
    
    private let observer: Observer
    private let cancel: Disposable
    
    private var isDisposed: Bool = false
    private var isStopped: Bool = false
    
    private let map: (SourceElement) -> Observable<DestinationElement>
    
    private var subscribeDisposable: SingleAssignmentDisposable = SingleAssignmentDisposable()
    private var disposables: [Disposable] = []
    
    init(observer: Observer, cancel: Disposable, map: @escaping (SourceElement) -> Observable<DestinationElement>) {
        self.observer = observer
        self.cancel = cancel
        self.map = map
    }
    
    func on(_ event: Event<SourceElement>) {
        guard !self.isStopped else { return }
        
        switch event {
        case .next(let s):
            let observable = self.map(s)
            let proxy = FlatMapSinkProxy(observer: self.observer)
            let subscription = observable.subscribe(proxy)
            self.disposables.append(subscription)
        case .completed:
            self.isStopped = true
            self.observer.on(.completed)
            self.dispose()
        case .error(let error):
            self.isStopped = true
            self.observer.on(.error(error))
            self.dispose()
        }
    }
    
    func run(_ source: Observable<SourceElement>) -> Disposable {
        let subscription = source.subscribe(self)
        self.subscribeDisposable.setDisposable(subscription)
        return self.subscribeDisposable
    }
    
    func dispose() {
        guard !self.isDisposed else { return }
        self.isDisposed = true
        self.disposables.forEach { $0.dispose() }
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
