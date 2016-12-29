//
//  LatestRecordPresenter.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift
import URLRouter

typealias ILatestRecordPresenter = (ILatestRecordInteractor, ILatestRecordView, @escaping URLRouter, DisposeBag) -> Void
let LatestRecordPresenter: ILatestRecordPresenter = { interactor, view, router, disposeBag in
    view.rx_viewDidLoad
        .flatMap { interactor.rx_findLatest() }
        .map { LatestRecordViewModel.from(fitnessInfo: $0) }
        .bindTo(view.rx_viewModel)
        .addDisposableTo(disposeBag)
    
    view.rx_didSelectMetric
        .subscribe(onNext: { metric in
            _ = router(URL(string: "app://records/history?metric=\(metric.rawValue)")!) { viewController in
                guard let viewController = viewController as? UIViewController else { fatalError() }
                
                UIApplication.shared.keyWindow?.rootViewController?.show(viewController, sender: nil)
            }
        }).addDisposableTo(disposeBag)

    interactor.rx_latestRecordUpdate
        .flatMap { interactor.rx_findLatest() }
        .map { LatestRecordViewModel.from(fitnessInfo: $0) }
        .bindTo(view.rx_viewModel)
        .addDisposableTo(disposeBag)
}
