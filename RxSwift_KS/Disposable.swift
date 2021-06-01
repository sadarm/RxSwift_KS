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

public class SingleAssignmentDisposable: Disposable {
    
    private var isDisposed: Bool = false
    private var disposable: Disposable?
    
    public func setDisposable(_ disposable: Disposable) {
        self.disposable = disposable
        if self.isDisposed {
            disposable.dispose()
            self.disposable = nil
        }
    }
    
    public func dispose() {
        guard !self.isDisposed else { return }
        self.isDisposed = true
        self.disposable?.dispose()
        self.disposable = nil
    }
}
