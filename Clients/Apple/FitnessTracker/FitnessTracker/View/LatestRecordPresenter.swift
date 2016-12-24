//
//  LatestRecordPresenter.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias ILatestRecordPresenter = (ILatestRecordInteractor, ILatestRecordView, DisposeBag) -> Void
let LatestRecordPresenter: ILatestRecordPresenter = { interactor, view, disposeBag in
    view.rx_viewDidLoad
        .flatMap { interactor.rx_findLatest() }
        .map { LatestRecordViewModel.from(fitnessInfo: $0) }
        .bindTo(view.rx_viewModel)
        .addDisposableTo(disposeBag)

    interactor.rx_latestRecordUpdate
        .flatMap { interactor.rx_findLatest() }
        .map { LatestRecordViewModel.from(fitnessInfo: $0) }
        .bindTo(view.rx_viewModel)
        .addDisposableTo(disposeBag)
}
