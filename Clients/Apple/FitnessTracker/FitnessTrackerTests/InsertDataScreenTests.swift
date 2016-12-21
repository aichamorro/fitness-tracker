//
//  InsertRecordScreenTests.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 21/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxTest
@testable import FitnessTracker

protocol IInsertRecordView {
    var rx_height: Observable<UInt> { get }
    var rx_weight: Observable<Double> { get }
    var rx_bodyFatPercentage: Observable<Double> { get }
    var rx_musclePercentage: Observable<Double> { get }
}

class InsertRecordView {
    var viewModel = InsertRecordViewModel()
}

protocol IInsertRecordViewModel {
    var height: UInt { get set }
    var weight: Double { get set }
    var bodyFatPercentage: Double { get set }
    var musclePercentage: Double { get set }
}

struct InsertRecordViewModel {
    var heightVariable: Variable<UInt>
    var weightVariable: Variable<Double>
    var bodyFatPercentageVariable: Variable<Double>
    var musclePercentageVariable: Variable<Double>
    
    init() {
        self.init(height: 0, weight: 0, bodyFatPercentage: 0, musclePercentage: 0)
    }
    
    init(height: UInt, weight: Double, bodyFatPercentage: Double, musclePercentage: Double) {
        heightVariable = Variable(height)
        weightVariable = Variable(weight)
        bodyFatPercentageVariable = Variable(bodyFatPercentage)
        musclePercentageVariable = Variable(musclePercentage)
    }
}

extension InsertRecordViewModel: IInsertRecordViewModel {
    var height: UInt {
        get { return heightVariable.value }
        set { heightVariable.value = newValue}
    }
    
    var weight: Double {
        get { return weightVariable.value }
        set { weightVariable.value = newValue }
    }
    
    var bodyFatPercentage: Double {
        get { return bodyFatPercentageVariable.value }
        set { bodyFatPercentageVariable.value = newValue }
    }
    
    var musclePercentage: Double {
        get { return musclePercentageVariable.value }
        set { musclePercentageVariable.value = newValue }
    }
}

extension InsertRecordView: IInsertRecordView {
    var rx_height: Observable<UInt> { return viewModel.heightVariable.asObservable() }
    var rx_weight: Observable<Double> { return viewModel.weightVariable.asObservable() }
    var rx_bodyFatPercentage: Observable<Double> { return viewModel.bodyFatPercentageVariable.asObservable() }
    var rx_musclePercentage: Observable<Double> { return viewModel.musclePercentageVariable.asObservable() }
}

protocol IInsertRecordInteractor { }
struct InsertRecordInteractor: IInsertRecordInteractor {
    let repository: IFitnessInfoRepository
}

typealias IInsertRecordPresenter = (IInsertRecordInteractor, IInsertRecordView, DisposeBag) -> Void

class InsertRecordScreenTests: QuickSpec {
    override func spec() {
        describe("As user I would like to be able to introduce body measurment records") {
//            it("Can store new measurements") {
//                let scheduler = TestScheduler(initialClock: 0)
//                let disposeBag = DisposeBag()
//                let record = FitnessInfo(weight: 66.7, height: 171, bodyFatPercentage: 31.0, musclePercentage: 34.0)
//                let interactor = InsertRecordInteractor(repository: MockFitnessInfoRepository(mockLastRecord: record))
//                
//                createObserverAndSubscribe(to: interactor.rx_lastRecord, scheduler: scheduler, disposeBag: disposeBag, expect: { (record) in
//                    expect(record)
//                }, action: {
//                    
//                    view.rx_saveRecord.onNext()
//                })
//            }
//            
//            it("Can get the height, weight, bodyFat and muscle percentages") {
//                let view = InsertRecordView()
//                let scheduler = TestScheduler(initialClock: 0)
//                let disposeBag = DisposeBag()
//                
//                createObserverAndSubscribe(to: view.rx_height.skip(1), scheduler: scheduler, disposeBag: disposeBag, expect: {
//                    expect($0).to(equal(175))
//                }, action: {
//                    view.viewModel.height = 175
//                })
//            }
        }
    }
}
