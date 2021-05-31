//
//  Disposable.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/05/30.
//

import Foundation

public protocol Disposable {
    func dispose()
}

public class Disposables {
    public static func create(_ dispose: @escaping () -> Void = { }) -> Disposable {
        return AnyDisposable(dispose)
    }
}

public class AnyDisposable: Disposable {
    let _dispose: () -> Void
    
    init(_ dispose: @escaping () -> Void) {
        self._dispose = dispose
    }
    
    public func dispose() {
        self._dispose()
    }
}
