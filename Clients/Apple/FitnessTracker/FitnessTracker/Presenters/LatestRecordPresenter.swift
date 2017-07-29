//
//  LatestRecordPresenter.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias ILatestRecordPresenter = (IFindLatestRecord, IRecordStoreUpdate, ILatestRecordView, AppRouter, DisposeBag) -> Void
let LatestRecordPresenter: ILatestRecordPresenter = { interactor, storeUpdates, view, router, disposeBag in

    interactor.rx_output
        .map { LatestRecordViewModel.from(fitnessInfo: $0) }
        .bindTo(view.rx_viewModel)
        .addDisposableTo(disposeBag)

    view.rx_viewDidLoad
        .bindTo(interactor.rx_input)
        .addDisposableTo(disposeBag)

    view.rx_didSelectMetric
        .subscribe(onNext: { metric in
            guard let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
            let rootViewController = tabController.viewControllers?.first as? UINavigationController else { fatalError() }

            router.showMetricHistoricData(metric: metric).push(in: rootViewController)
        }).addDisposableTo(disposeBag)

    interactor.rx_output
        .map { LatestRecordViewModel.from(fitnessInfo: $0) }
        .bindTo(view.rx_viewModel)
        .addDisposableTo(disposeBag)

    storeUpdates.rx_didUpdate
        .bindTo(interactor.rx_input)
        .addDisposableTo(disposeBag)
}
