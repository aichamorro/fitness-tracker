//
//  NewRecordPresenter.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 21/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias INewRecordPresenter =
    (ILatestRecordInteractor,
    INewRecordInteractor,
    INewRecordView,
    DisposeBag) -> Void

let NewRecordPresenter: INewRecordPresenter = { latestRecordInteractor, insertNewRecordInteractor, view, disposeBag in
    let loadLatestResult: () -> Void = {
        latestRecordInteractor
            .rx_findLatest()
            .bindNext(mapFitnessInfoToView(view: view))
            .addDisposableTo(disposeBag)
    }
    
    view.rx_viewDidLoad
        .subscribe(onNext: { loadLatestResult() })
        .addDisposableTo(disposeBag)
    
    view.rx_actionSave
        .flatMap(mapViewModelToFitnessInfo)
        .flatMap { insertNewRecordInteractor.rx_save(record: $0) }
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
    }
}

func mapViewModelToFitnessInfo(viewModel: NewRecordViewModel) -> Observable<IFitnessInfo> {
    let fitnessInfo = FitnessInfo(weight: viewModel.weight,
                                  height: viewModel.height,
                                  bodyFatPercentage: viewModel.bodyFat,
                                  musclePercentage: viewModel.muscle)
    
    return Observable.just(fitnessInfo)
}
