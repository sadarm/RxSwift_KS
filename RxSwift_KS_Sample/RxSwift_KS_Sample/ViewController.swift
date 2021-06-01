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
            print("downloadImage")
            observer.on(.next(1))

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                observer.on(.next(2))
                observer.on(.completed)
                observer.on(.next(2))
            })
            return Disposables.create {
                print("disposed downloadImage")
            }
        }
    }
    
    func presentImage(_ image: Int) -> Observable<String> {
        return Observable.create { observer in
            observer.on(.next("present: \(image)"))
            observer.on(.completed)
            return Disposables.create {
                print("disposed presentImage")
            }
        }
    }
    
    private var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.downloadImage.flatMap { self.presentImage($0) }.subscribe(AnyObserver { event in
            print("\(event)")
        }).disposed(by: self.disposeBag)
    }
}

