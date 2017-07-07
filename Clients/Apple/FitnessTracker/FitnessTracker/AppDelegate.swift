//
//  AppDelegate.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 13/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import UIKit
import RxSwift

typealias RetainerBag = [Any]

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var disposeBag = DisposeBag()

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        #if DEBUG
            do {
                try R.validate()
            } catch {
                fatalError("R.swift does not validate")
            }
        #endif

        return true
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        configureServices()

        let router: AppRouter = ServiceLocator.inject()
        let mainTabController = UITabBarController()
        mainTabController.viewControllers = [router.currentRecord().viewController, router.insights().viewController]
        window?.rootViewController = mainTabController

        return true
    }

    private func configureServices() {
        CoreDataStackInitializer({ managedObjectContext in
            NSLog("Core Data Stack initialized correctly")

            let coreDataEngine = CoreDataEngineImpl(managedObjectContext: managedObjectContext)

            ServiceLocator.registerSingleton(coreDataEngine as CoreDataEngine)
            ServiceLocator.registerCoreDataRepositories()
        }, { error in
            fatalError(error.localizedDescription)
        })
    }
}
