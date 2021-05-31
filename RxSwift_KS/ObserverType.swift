//
//  ObserverType.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/05/30.
//

import Foundation

public enum Event<Element> {
    case next(Element)
    case completed
    case error(Error)
}

public protocol ObserverType {
    associatedtype Element
    
    func on(_ event: Event<Element>)
}

