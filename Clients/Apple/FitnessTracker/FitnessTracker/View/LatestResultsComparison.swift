//
//  LatestResultsComparison.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 23/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IShowPreviousLatestResultInteractor {
    func rx_previousLatestResult() -> Observable<IFitnessInfo>
}

class ShowPreviousLatestResultInteractor: IShowPreviousLatestResultInteractor {
    let repository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }
    
    func rx_previousLatestResult() -> Observable<IFitnessInfo> {
        return repository.findLatest(numberOfRecords: 2).flatMap { info in
            Observable.create { observer in
                observer.onNext(info.count == 2 ? info[1] : FitnessInfo.empty)
                observer.onCompleted()
                
                return Disposables.create()
            }
        }
    }
}

protocol IShowPreviousLatestResultView {
    var rx_needsRefresh: Observable<Void> { get }
    var rx_comparisonViewModel: AnyObserver<HomeScreenViewModel> { get }
}

typealias IShowPreviousLatestResultPresenter = (IShowPreviousLatestResultInteractor, IShowPreviousLatestResultView, DisposeBag) -> Void
let LatestResultsComparisonPresenter: IShowPreviousLatestResultPresenter = { interactor, view, disposeBag in
    view.rx_needsRefresh
        .flatMap { interactor.rx_previousLatestResult() }
        .map { info in HomeScreenViewModel.from(fitnessInfo: info) }
        .bindTo(view.rx_comparisonViewModel)
        .addDisposableTo(disposeBag)
}
