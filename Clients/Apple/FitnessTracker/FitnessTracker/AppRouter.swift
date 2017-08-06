//
//  AppRouter.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 03/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol AppRouter {
    func currentRecord() -> UIWireframe
    func addRecordEntry() -> UIWireframe
    func showMetricHistoricData(metric: BodyMetric) -> UIWireframe
    func insights() -> UIWireframe
}

final class DefaultAppRouter {
}

extension ServiceLocator {
    static var viewControllerFactory: IUIViewControllerFactory {
        return ServiceLocator.inject()
    }

    static var router: AppRouter {
        return ServiceLocator.inject()
    }
}

extension DefaultAppRouter: AppRouter {
    func currentRecord() -> UIWireframe {
        let latestRecordInteractor = FindLatestRecord(repository: ServiceLocator.inject())
        let latestResultsComparisonInteractor = FindPreviousLatestRecord(repository: ServiceLocator.inject())
        let storeUpdates = RecordStoreUpdate(repository: ServiceLocator.inject())

        let disposeBag = DisposeBag()

        let viewController = ServiceLocator.viewControllerFactory.latestRecordViewController()
        viewController.title = LocalizableStrings.Records.Latest.title()
        viewController.interactors = [latestRecordInteractor, latestResultsComparisonInteractor]
        viewController.disposeBag = disposeBag
        viewController.router = ServiceLocator.router

        LatestRecordPresenter(latestRecordInteractor, storeUpdates, viewController as ILatestRecordView, ServiceLocator.router, disposeBag)
        LatestResultsComparisonPresenter(latestResultsComparisonInteractor, viewController, disposeBag)

        return UIWireframe(viewController: viewController).embeddedInNavigationController()
    }

    func addRecordEntry() -> UIWireframe {
        let viewController = ServiceLocator.viewControllerFactory.newRecordViewController()

        let seeLatestRecordInteractor = FindLatestRecord(repository: ServiceLocator.inject())
        let insertNewRecordInteractor = CreateNewRecord(repository: ServiceLocator.inject(),
                                                        healthKitRepository: ServiceLocator.inject())
        let disposeBag = DisposeBag()

        viewController.interactors = [seeLatestRecordInteractor, insertNewRecordInteractor]
        viewController.disposeBag = disposeBag
        NewRecordPresenter(seeLatestRecordInteractor, insertNewRecordInteractor, viewController, disposeBag)

        return UIWireframe(viewController: viewController)
    }

    func showMetricHistoricData(metric: BodyMetric) -> UIWireframe {
        let viewController = ServiceLocator.viewControllerFactory.showMetricHistoryData()
        let disposeBag = DisposeBag()

        viewController.selectedMetric = metric
        let historicDataInteractor = FindAllRecords(repository: ServiceLocator.inject())
        let recordsFinderInteractor = FindRecordsInInterval(repository: ServiceLocator.inject())
        let removeRecordInteractor = RemoveReadingInteractorImpl(repository: ServiceLocator.inject())
        viewController.bag = [historicDataInteractor, recordsFinderInteractor, removeRecordInteractor, disposeBag]

        MetricHistoryPresenter(historicDataInteractor, viewController, disposeBag)
        MetricGraphPresenter(recordsFinderInteractor, viewController, disposeBag)
        RemoveReadingPresenterImpl(removeRecordInteractor, viewController, disposeBag)

        return UIWireframe(viewController: viewController)
    }

    func insights() -> UIWireframe {
        let viewController = ServiceLocator.viewControllerFactory.showInsights()
        viewController.title = LocalizableStrings.Insights.title()

        let insightsInteractor = FindInsights(repository: ServiceLocator.inject())
        let recordStoreUpdates = RecordStoreUpdate(repository: ServiceLocator.inject())
        let disposeBag = DisposeBag()

        viewController.bag = [disposeBag]
        InsightsPresenter(insightsInteractor, recordStoreUpdates, viewController, disposeBag)

        return UIWireframe(viewController: viewController)
    }

}
