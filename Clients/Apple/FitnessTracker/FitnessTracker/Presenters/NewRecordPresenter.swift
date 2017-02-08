//
//  NewRecordPresenter.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 21/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias NewRecordViewModel = (height: UInt, weight: Double, muscle: Double, bodyFat: Double, water: Double)
private func record(applyingCalibration calibration: Double, to record: NewRecordViewModel) -> NewRecordViewModel {
    return NewRecordViewModel(height: record.height,
                              weight: record.weight * calibration,
                              muscle: record.muscle,
                              bodyFat: record.bodyFat,
                              water: record.water)
}

typealias INewRecordPresenter =
    (IFindLatestRecord,
    ICreateNewRecord,
    INewRecordView,
    DisposeBag) -> Void

let NewRecordPresenter: INewRecordPresenter = { latestRecordInteractor, insertNewRecordInteractor, view, disposeBag in
    let loadLatestResult: () -> Void = {
        latestRecordInteractor
            .rx_find()
            .bindNext(mapFitnessInfoToView(view: view))
            .addDisposableTo(disposeBag)
    }
    
    view.rx_viewDidLoad
        .subscribe(onNext: { loadLatestResult() })
        .addDisposableTo(disposeBag)
    
    view.rx_actionSave
        .flatMap {
            Observable.just(record(applyingCalibration: view.calibrationFix, to: $0))
        }.flatMap(mapViewModelToFitnessInfo)
        .flatMap { insertNewRecordInteractor.rx_save($0) }
        .do(onNext: { _ in loadLatestResult() })
        .subscribe { _ in view.dismiss() }
        .addDisposableTo(disposeBag)
}

// MARK: Maps

func mapFitnessInfoToView(view: INewRecordView) -> (IFitnessInfo) -> Void {
    return { info in
        view.height = info.height
        view.weight = info.weight
        view.bodyFatPercentage = info.bodyFatPercentage
        view.musclePercentage = info.musclePercentage
        view.waterPercentage = info.waterPercentage
    }
}

func mapViewModelToFitnessInfo(viewModel: NewRecordViewModel) -> Observable<IFitnessInfo> {
    let fitnessInfo = FitnessInfo(weight: viewModel.weight,
                                  height: viewModel.height,
                                  bodyFatPercentage: viewModel.bodyFat,
                                  musclePercentage: viewModel.muscle,
                                  waterPercentage: viewModel.water)
    
    return Observable.just(fitnessInfo)
}
