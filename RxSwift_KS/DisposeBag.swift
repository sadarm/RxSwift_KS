//
//  DisposeBag.swift
//  RxSwift_KS
//
//  Created by kisupark on 2021/05/31.
//

import Foundation

public final class DisposeBag {
    
    private var disposables: [Disposable] = []
    
    deinit {
        self.dispose()
    }
    
    public init() {
        
    }
    
    private func dispose() {
        self.disposables.forEach { $0.dispose() }
        self.disposables.removeAll(keepingCapacity: false)
    }
    
    func addDisposable(_ disposable: Disposable) {
        self.disposables.append(disposable)
    }

}

extension Disposable {
    public func disposed(by disposeBag: DisposeBag) {
        disposeBag.addDisposable(self)
    }
}
