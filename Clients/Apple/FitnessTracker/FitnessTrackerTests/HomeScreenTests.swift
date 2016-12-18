//
//  HomeScreenTests.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 14/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxTest
@testable import FitnessTracker

struct MockFitnessInfoRepository: IFitnessInfoRepository {
    let mockLastRecord: IFitnessInfo
    
    func getLastRecord(success: (IFitnessInfo) -> Void, error: (Error) -> Void) {
        success(mockLastRecord)
    }
}

class HomeScreenTests: QuickSpec {
    override func spec() {
        describe("So that I can see my fitness info at one glance, as user I would like to see the latest measurements") {
            context("Showing measurements") {
                
                var view: HomeScreenView!
                var disposeBag: DisposeBag!
                var scheduler: TestScheduler!
                var presenter: IHomeScreenPresenter!
                
                beforeEach {
                    view = HomeScreenView()
                    disposeBag = DisposeBag()
                    scheduler = TestScheduler(initialClock: 0)
                    presenter = HomeScreenPresenter
                }
                
                afterEach {
                    view.rx_height.onCompleted()
                    view.rx_weight.onCompleted()
                    view.rx_musclePercentage.onCompleted()
                    view.rx_bodyFatPercentage.onCompleted()

                    presenter = nil
                    view = nil
                }
                
                it("Shows the latest record data") {
                    let heightObserver = scheduler.createObserver(UInt.self)
                    view.height.asObservable().subscribe(heightObserver).addDisposableTo(disposeBag)
                    
                    let weightObserver = scheduler.createObserver(Double.self)
                    view.weight.asObservable().subscribe(weightObserver).addDisposableTo(disposeBag)
                    
                    let bodyFatObserver = scheduler.createObserver(Double.self)
                    view.bodyFatPercentage.asObservable().subscribe(bodyFatObserver).addDisposableTo(disposeBag)
                    
                    let muscleObserver = scheduler.createObserver(Double.self)
                    view.musclePercentage.asObservable().subscribe(muscleObserver).addDisposableTo(disposeBag)

                    let mockRepository = MockFitnessInfoRepository(mockLastRecord: FitnessInfo(weight: 34.5, height: 171, bodyFatPercentage: 30.0, musclePercentage: 30.0))
                    let interactor = HomeScreenInteractor(repository: mockRepository)
                    presenter(interactor, view, disposeBag)
                    
                    createObserverAndSubscribe(to: interactor.rx_currentRecord, scheduler: scheduler, disposeBag: disposeBag, expect: { _ in
                        guard let observedWeight = weightObserver.events.first!.value.element else { fatalError() }
                        guard let observedHeight = heightObserver.events.first!.value.element else { fatalError() }
                        guard let observedBodyFat = bodyFatObserver.events.first!.value.element else { fatalError() }
                        guard let observedMuscle = muscleObserver.events.first!.value.element else { fatalError() }

                        expect(observedWeight - 34.5 < 0.000001).to(beTrue())
                        expect(observedHeight).to(equal(171))
                        expect(observedBodyFat - 30.0 < 0.000001).to(beTrue())
                        expect(observedMuscle - 30.0 < 0.000001).to(beTrue())
                    }, action: {
                        view.viewDidLoad.onNext()
                    })
                }
                
                it("Can show the weight") {
                    createObserverAndSubscribe(to: view.weight, scheduler: scheduler, disposeBag: disposeBag, expect: {
                        expect($0).to(equal(34.5))
                    }, action: {
                        view.rx_weight.onNext(34.5)
                    })
                }
                
                it("Can show the height") {
                    createObserverAndSubscribe(to: view.height, scheduler: scheduler, disposeBag: disposeBag, expect: {
                        expect($0).to(equal(171))
                    }, action: {
                        view.rx_height.onNext(171)
                    })
                }
                
                it("Can show the body fat percentage") {
                    createObserverAndSubscribe(to: view.bodyFatPercentage, scheduler: scheduler, disposeBag: disposeBag, expect: {
                        expect($0 - 30.0 < 0.000001).to(beTrue())
                    }, action: { 
                        view.rx_bodyFatPercentage.onNext(30.0)
                    })
                }
                
                it("Can show the muscle percentage") {
                    createObserverAndSubscribe(to: view.musclePercentage, scheduler: scheduler, disposeBag: disposeBag, expect: {
                        expect($0 - 30.0 < 0.000001).to(beTrue())
                    }, action: {
                        view.rx_musclePercentage.onNext(30.0)
                    })
                }

            }
        }
    }
}

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
