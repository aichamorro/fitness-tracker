//
//  HomeScreenPresenter.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias IHomeScreenPresenter = (IHomeScreenInteractor, IHomeScreenView, DisposeBag) -> Void
let HomeScreenPresenter: IHomeScreenPresenter = { interactor, view, disposeBag in
    view.rx_viewDidLoad
        .bindNext {
            interactor.loadLastRecord()
        }.addDisposableTo(disposeBag)
    
    interactor.rx_currentRecord
        .map { HomeScreenViewModel(weight: $0.weight,
                                   height: $0.height,
                                   bodyFat: $0.bodyFatPercentage,
                                   muscle: $0.musclePercentage) }
        .bindTo(view.rx_viewModel)
        .addDisposableTo(disposeBag)
}
