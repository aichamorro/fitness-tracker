//
//  RemoveReadingPresenter.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 05/08/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol RemoveReadingView {
    var rx_removeReading: Observable<IFitnessInfo> { get }
}

typealias RemoveReadingPresenter = (RemoveReadingInteractor, RemoveReadingView, DisposeBag) -> Void
let RemoveReadingPresenterImpl: RemoveReadingPresenter = { removeReading, removeReadingView, disposeBag in
    removeReadingView.rx_removeReading
        .bindTo(removeReading.rx_input)
        .addDisposableTo(disposeBag)
}
