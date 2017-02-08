//
//  LatestResultsComparison.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 23/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IShowPreviousLatestResultView {
    var rx_needsRefresh: Observable<Void> { get }
    var rx_comparisonViewModel: AnyObserver<LatestRecordViewModel> { get }
}

typealias IShowPreviousLatestResultPresenter = (IFindPreviousLatestRecord, IShowPreviousLatestResultView, DisposeBag) -> Void
let LatestResultsComparisonPresenter: IShowPreviousLatestResultPresenter = { interactor, view, disposeBag in
    view.rx_needsRefresh
        .flatMap { interactor.rx_find() }
        .map { info in LatestRecordViewModel.from(fitnessInfo: info) }
        .bindTo(view.rx_comparisonViewModel)
        .addDisposableTo(disposeBag)
}
