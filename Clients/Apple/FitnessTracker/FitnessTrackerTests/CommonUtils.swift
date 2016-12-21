//
//  CommonUtils.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 21/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift
import RxTest
import Quick
import Nimble

func createObserverAndSubscribe<T>(to observable: Observable<T>, scheduler: TestScheduler, disposeBag: DisposeBag, expect: (T) -> Void, action: @escaping (()->Void)) {
    let observer = scheduler.createObserver(T.self)
    
    waitUntil { done in
        observable.subscribe(onNext: {_ in done() }).addDisposableTo(disposeBag)
        observable.subscribe(observer).addDisposableTo(disposeBag)
        action()
    }
    
    let actual = observer.events.first!.value.element!
    expect(actual)
}
