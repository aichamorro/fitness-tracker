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
    static private func currentRecordEntry(serviceLocator: AppServiceLocator) -> URLRouterEntry {
        return URLRouterEntryFactory.with(pattern: "app://records") { _,_ in
            let latestRecordInteractor = LatestRecordInteractor(repository: serviceLocator.fitnessInfoRepository)
            let latestResultsComparisonInteractor = ShowPreviousLatestResultInteractor(repository: serviceLocator.fitnessInfoRepository)
            
            let view = LatestRecordView()
            let disposeBag = DisposeBag()
            
            guard let viewController = serviceLocator.mainStoryboard.instantiateInitialViewController() as? LatestRecordViewController else {
                fatalError()
            }
            
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
            let viewController = serviceLocator.mainStoryboard.instantiateViewController(withIdentifier: "NewRecordViewController") as? NewRecordViewController
            guard viewController != nil else { fatalError() }
            
            let seeLatestRecordInteractor = LatestRecordInteractor(repository: serviceLocator.fitnessInfoRepository)
            let insertNewRecordInteractor = NewRecordInteractor(repository: serviceLocator.fitnessInfoRepository)
            let disposeBag = DisposeBag()
            
            viewController!.interactors = [seeLatestRecordInteractor, insertNewRecordInteractor]
            viewController!.disposeBag = disposeBag
            NewRecordPresenter(seeLatestRecordInteractor, insertNewRecordInteractor, viewController!, disposeBag)
            
            return viewController
        }
    }
    
    static private func showMetricHistoricData(serviceLocator: AppServiceLocator) -> URLRouterEntry {
        return URLRouterEntryFactory.with(pattern: "app://records/history/:metric") { _, parameters -> Any? in
            let viewController = serviceLocator.mainStoryboard.instantiateViewController(withIdentifier: "ShowMetricHistoricalData") as? ShowMetricHistoricalDataViewController
            guard viewController != nil else { fatalError() }
            let disposeBag = DisposeBag()
            
            viewController!.selectedMetric = BodyMetric(rawValue: parameters["metric"]!)!
            let historicDataInteractor = MetricHistoryInteractor(repository: serviceLocator.fitnessInfoRepository)
            viewController!.bag = [historicDataInteractor, disposeBag]
            
            MetricHistoryPresenter(historicDataInteractor, viewController!, disposeBag)
            
            return viewController
        }
    }
    
    static func allEntries(serviceLocator: AppServiceLocator) -> [URLRouterEntry] {
        return [currentRecordEntry(serviceLocator: serviceLocator),
                createRecordEntry(serviceLocator: serviceLocator),
                showMetricHistoricData(serviceLocator: serviceLocator)]
    }
    
}
