//
//  AppDelegate.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 13/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import UIKit
import URLRouter
import RxSwift

class AppServiceLocator {
    var fitnessInfoRepository: IFitnessInfoRepository!
    var router: URLRouter!
}

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var router: URLRouter!
    var serviceLocator: AppServiceLocator!
    var disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        serviceLocator = AppServiceLocator()
        
        CoreDataStackInitializer()
            .subscribeOn(MainScheduler.instance)
            .do(onNext: { _ in NSLog("Core Data Stack initialized correctly")},
                onError: { error in NSLog("Failure while initializing Core Data Stack: \(error)") })
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
            
                self.serviceLocator.fitnessInfoRepository = CoreDataInfoRepository(managedObjectContext: $0)
            }, onError: { _ in
                fatalError()
            }).addDisposableTo(disposeBag)

        router = URLRouterFactory.with(entries: urlEntries())
        _ = router(URL(string: "app://records")!) { controller in
            guard let viewController = controller as? UIViewController else { fatalError() }
            viewController.title = NSLocalizedString("Last measurement", comment: "Last measurement")
            let rootController = UINavigationController(rootViewController: viewController)
            
            self.window?.rootViewController = rootController
        }
        
        serviceLocator.router = router
        
        // Override point for customization after application launch.
        return true
    }
    
    private func urlEntries() -> [URLRouterEntry] {
        let serviceLocator = self.serviceLocator!
        
        let currentRecordURLPattern = URLRouterEntryFactory.with(pattern: "app://records") { [weak self] _,_ in
            let latestRecordInteractor = LatestRecordInteractor(repository: serviceLocator.fitnessInfoRepository)
            let latestResultsComparisonInteractor = ShowPreviousLatestResultInteractor(repository: serviceLocator.fitnessInfoRepository)
            
            let view = LatestRecordView()
            let disposeBag = DisposeBag()
            
            guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? LatestRecordViewController else {
                fatalError()
            }
            
            viewController.interactors = [latestRecordInteractor, latestResultsComparisonInteractor]
            viewController.disposeBag = disposeBag
            viewController.latestRecordView = view
            viewController.router = self?.router
            
            LatestRecordPresenter(latestRecordInteractor, view, disposeBag)
            LatestResultsComparisonPresenter(latestResultsComparisonInteractor, viewController, disposeBag)
            
            return viewController
        }
        
        let createRecordURLPattern = URLRouterEntryFactory.with(pattern: "app://records/new") { _,_ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "NewRecordViewController") as? NewRecordViewController
            guard viewController != nil else { fatalError() }
            
            let seeLatestRecordInteractor = LatestRecordInteractor(repository: serviceLocator.fitnessInfoRepository)
            let insertNewRecordInteractor = NewRecordInteractor(repository: serviceLocator.fitnessInfoRepository)
            let disposeBag = DisposeBag()
            
            viewController!.interactors = [seeLatestRecordInteractor, insertNewRecordInteractor]
            viewController!.disposeBag = disposeBag
            NewRecordPresenter(seeLatestRecordInteractor, insertNewRecordInteractor, viewController!, disposeBag)
            
            return viewController
        }
        
        return [currentRecordURLPattern, createRecordURLPattern]
    }

}

