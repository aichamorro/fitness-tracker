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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var router: URLRouter!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let entry = URLRouterEntryFactory.with(pattern: "app://records") { _,_ in
            let record = FitnessInfo(weight: 59.20, height: 154, bodyFatPercentage: 26.6, musclePercentage: 31.1)
            let repository = MockFitnessInfoRepository(mockLastRecord: record)
            let interactor = HomeScreenInteractor(repository: repository)
            let view = HomeScreenView()
            let disposeBag = DisposeBag()
            
            guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? HomeScreenViewController else {
                fatalError()
            }
            
            viewController.interactor = interactor
            viewController.disposeBag = disposeBag
            viewController.homeScreenView = view
            
            HomeScreenPresenter(interactor, view, disposeBag)

            return viewController
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        router = URLRouterFactory.with(entries: [entry])
        _ = router(URL(string: "app://records")!) { controller in
            guard let viewController = controller as? UIViewController else { fatalError() }
            viewController.title = NSLocalizedString("Last measurement", comment: "Last measurement")
            let rootController = UINavigationController(rootViewController: viewController)
            
            self.window?.rootViewController = rootController
        }
        
        // Override point for customization after application launch.
        return true
    }

}

