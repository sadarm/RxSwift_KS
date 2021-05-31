//
//  AnyObserver.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/05/30.
//

import Foundation

public class AnyObserver<Element>: ObserverType {
    public typealias EventHandler = (Event<Element>) -> Void
    let observer: EventHandler
    
    public init(eventHandler: @escaping EventHandler) {
        self.observer = eventHandler
    }
    
    init<Observer: ObserverType>(_ observer: Observer) where Observer.Element == Element {
        self.observer = observer.on
    }
    
    public func on(_ event: Event<Element>) {
        self.observer(event)
    }
}
