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
        .map { HomeScreenViewModel.from(fitnessInfo: $0) }
        .bindTo(view.rx_viewModel)
        .addDisposableTo(disposeBag)
}
