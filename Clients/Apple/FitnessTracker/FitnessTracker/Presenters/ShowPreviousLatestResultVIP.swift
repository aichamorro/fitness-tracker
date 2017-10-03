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
    interactor.rx_output
        .map { info in LatestRecordViewModel.from(fitnessInfo: info) }
        .bind(to: view.rx_comparisonViewModel)
        .disposed(by: disposeBag)

    view.rx_needsRefresh
        .bind(to: interactor.rx_input)
        .disposed(by: disposeBag)
}
