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
        .bind(to: view.rx_viewModel)
        .disposed(by: disposeBag)

    view.rx_viewDidLoad
        .bind(to: interactor.rx_input)
        .disposed(by: disposeBag)

    view.rx_didSelectMetric
        .subscribe(onNext: { metric in
            guard let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
            let rootViewController = tabController.viewControllers?.first as? UINavigationController else { fatalError() }

            router.showMetricHistoricData(metric: metric).push(in: rootViewController)
        }).disposed(by: disposeBag)

    interactor.rx_output
        .map { LatestRecordViewModel.from(fitnessInfo: $0) }
        .bind(to: view.rx_viewModel)
        .disposed(by: disposeBag)

    storeUpdates.rx_didUpdate
        .bind(to: interactor.rx_input)
        .disposed(by: disposeBag)
}
