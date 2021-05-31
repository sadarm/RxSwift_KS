//
//  Observable.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/05/30.
//

import Foundation

public class Observable<Element>: ObservableType {
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Element == Observer.Element {
        fatalError("not implemented")
    }
}
