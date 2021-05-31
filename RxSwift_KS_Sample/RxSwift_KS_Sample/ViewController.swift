//
//  ViewController.swift
//  RxSwift_KS_Sample
//
//  Created by kisupark on 2021/05/30.
//

import UIKit
import RxSwift_KS

class ViewController: UIViewController {
    
    var downloadImage: Observable<Int> {
        return Observable.create { observer in
            print("create")
            observer.on(.next(1))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                observer.on(.next(2))
                observer.on(.completed)
                observer.on(.next(2))
            })
            return Disposables.create {
                print("disposed")
            }
        }
    }
    
    private var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.downloadImage.subscribe(AnyObserver { event in
            print("\(event)")
        }).disposed(by: self.disposeBag)
    }
}

