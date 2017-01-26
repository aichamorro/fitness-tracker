//
//  AppRouter.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 03/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import URLRouter
import RxSwift

final class AppRouter {
    let urlRouter: URLRouter
    
    init(urlRouter: @escaping URLRouter) {
        self.urlRouter = urlRouter
    }
    
    @discardableResult func open(appURL url: URL, resultHandler: URLRouterResultHandler?) -> Bool {
        return urlRouter(url, resultHandler)
    }
}

extension AppRouter {
    static var empty: AppRouter {
        return AppRouter(urlRouter: URLRouterFactory.with(entries: []))
    }
}

extension AppRouter {
    static private func currentRecordEntry(serviceLocator: AppServiceLocator) -> URLRouterEntry {
        return URLRouterEntryFactory.with(pattern: "app://records") { _,_ in
            let latestRecordInteractor = LatestRecordInteractor(repository: serviceLocator.fitnessInfoRepository)
            let latestResultsComparisonInteractor = ShowPreviousLatestResultInteractor(repository: serviceLocator.fitnessInfoRepository)
            
            let view = LatestRecordView()
            let disposeBag = DisposeBag()
            
            let viewController = serviceLocator.viewControllerFactory.latestRecordViewController()
            viewController.interactors = [latestRecordInteractor, latestResultsComparisonInteractor]
            viewController.disposeBag = disposeBag
            viewController.latestRecordView = view
            viewController.router = serviceLocator.router
            
            LatestRecordPresenter(latestRecordInteractor, view, serviceLocator.router, disposeBag)
            LatestResultsComparisonPresenter(latestResultsComparisonInteractor, viewController, disposeBag)
            
            return viewController
        }
    }
    
    static private func createRecordEntry(serviceLocator: AppServiceLocator) -> URLRouterEntry {
        return URLRouterEntryFactory.with(pattern: "app://records/new") { _,_ in
            let viewController = serviceLocator.viewControllerFactory.newRecordViewController()
            
            let seeLatestRecordInteractor = LatestRecordInteractor(repository: serviceLocator.fitnessInfoRepository)
            let insertNewRecordInteractor = NewRecordInteractor(repository: serviceLocator.fitnessInfoRepository)
            let disposeBag = DisposeBag()
            
            viewController.interactors = [seeLatestRecordInteractor, insertNewRecordInteractor]
            viewController.disposeBag = disposeBag
            NewRecordPresenter(seeLatestRecordInteractor, insertNewRecordInteractor, viewController, disposeBag)
            
            return viewController
        }
    }
    
    static private func showMetricHistoricData(serviceLocator: AppServiceLocator) -> URLRouterEntry {
        return URLRouterEntryFactory.with(pattern: "app://records/history/:metric") { _, parameters -> Any? in
            let viewController = serviceLocator.viewControllerFactory.showMetricHistoryData()
            let disposeBag = DisposeBag()
            
            viewController.selectedMetric = BodyMetric(rawValue: parameters["metric"]!)!
            let historicDataInteractor = MetricHistoryInteractor(repository: serviceLocator.fitnessInfoRepository)
            viewController.bag = [historicDataInteractor, disposeBag]
            
            MetricHistoryPresenter(historicDataInteractor, viewController, disposeBag)
            
            return viewController
        }
    }
    
    static private func insights(serviceLocator: AppServiceLocator) -> URLRouterEntry {
        return URLRouterEntryFactory.with(pattern: "app://insights") { _,_ in
            let viewController = serviceLocator.viewControllerFactory.showInsights()
            let insightsInteractor = InsightsInteractor(repository: serviceLocator.fitnessInfoRepository)
            let disposeBag = DisposeBag()
            
            viewController.bag = [disposeBag]
            InsightsPresenter(insightsInteractor, viewController, disposeBag)

            return viewController
        }
    }
    
    static func allEntries(serviceLocator: AppServiceLocator) -> [URLRouterEntry] {
        return [currentRecordEntry(serviceLocator: serviceLocator),
                createRecordEntry(serviceLocator: serviceLocator),
                showMetricHistoricData(serviceLocator: serviceLocator),
                insights(serviceLocator: serviceLocator)]
    }
    
}
