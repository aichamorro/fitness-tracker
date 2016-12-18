//
//  HomeScreenPresenter.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias IHomeScreenPresenter = (IHomeScreenInteractor, HomeScreenView, DisposeBag) -> Void
let HomeScreenPresenter: IHomeScreenPresenter = { interactor, view, disposeBag in
    view.rx_viewDidLoad
        .bindNext { interactor.loadLastRecord() }
        .addDisposableTo(disposeBag)
    
    interactor.rx_currentRecord
        .bindNext { fitnessInfo in
            view.rx_weight.onNext(fitnessInfo.weight)
            view.rx_height.onNext(fitnessInfo.height)
            view.rx_bodyFatPercentage.onNext(fitnessInfo.bodyFatPercentage)
            view.rx_musclePercentage.onNext(fitnessInfo.musclePercentage)
        }.addDisposableTo(disposeBag)
}
