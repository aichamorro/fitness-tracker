//
//  LatestRecordTests.swift
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

class LatestRecordTests: QuickSpec {
    override func spec() {
        describe("So that I can see my fitness info at one glance, as user I would like to see the latest measurements") {
            context("Showing measurements") {
                
                var view: LatestRecordView!
                var disposeBag: DisposeBag!
                var scheduler: TestScheduler!
                var presenter: ILatestRecordPresenter!
                
                beforeEach {
                    view = LatestRecordView()
                    disposeBag = DisposeBag()
                    scheduler = TestScheduler(initialClock: 0)
                    presenter = LatestRecordPresenter
                }
                
                afterEach {
                    presenter = nil
                    view = nil
                    
                    scheduler.stop()
                    scheduler = nil
                }
                
                it("Shows the latest record data") {
                    let mockRepository = MockFitnessInfoRepository(mockLastRecord: FitnessInfo(weight: 34.5, height: 171, bodyFatPercentage: 30.0, musclePercentage: 30.0))
                    let interactor = LatestRecordInteractor(repository: mockRepository)
                    presenter(interactor, view, disposeBag)
                    
                    createObserverAndSubscribe(to: view.viewModelVariable.asObservable().skip(1), scheduler: scheduler, disposeBag: disposeBag, expect: { viewModel in
                        expect(viewModel.weight - 34.5 < 0.000001).to(beTrue())
                        expect(viewModel.height).to(equal(171))
                        expect(viewModel.bodyFat - 30.0 < 0.000001).to(beTrue())
                        expect(viewModel.muscle - 30.0 < 0.000001).to(beTrue())
                    }, action: {
                        view.viewDidLoad()
                    })
                }
            }
        }
    }
}

class MockFitnessInfoRepository: IFitnessInfoRepository {
    
    private let rx_latestSubject = PublishSubject<IFitnessInfo>()
    
    var mockLastRecord: IFitnessInfo!
    
    init(mockLastRecord: IFitnessInfo) {
        self.mockLastRecord = mockLastRecord
    }
    
    var rx_latest: Observable<IFitnessInfo> {
        return rx_latestSubject.asObservable()
    }
    
    func loadLatest() {
        rx_latestSubject.onNext(mockLastRecord)
    }
    
    func findLatest(numberOfRecords: Int) -> Observable<[IFitnessInfo]> {
        return Observable.just([FitnessInfo.empty])
    }
    
    func save(record: IFitnessInfo) -> Observable<IFitnessInfo> {
        mockLastRecord = record
        
        return Observable.just(mockLastRecord)
    }
}

