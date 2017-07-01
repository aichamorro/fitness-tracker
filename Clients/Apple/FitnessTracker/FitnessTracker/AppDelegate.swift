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
    var router: AppRouter!
    var viewControllerFactory: IUIViewControllerFactory!
}

typealias RetainerBag = [Any]

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var serviceLocator: AppServiceLocator!
    var disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        configureServices()
        configureRouting()
        
        var initialViewControllers: [UIViewController] = []
        serviceLocator.router.open(appURL: URL(string: "app://records")!) { controller in
            guard let viewController = controller as? UIViewController else { fatalError() }
            viewController.title = LocalizableStrings.Records.Latest.title()
            let rootController = UINavigationController(rootViewController: viewController)
            
            initialViewControllers.append(rootController)
        }
        
        serviceLocator.router.open(appURL: URL(string: "app://insights")!) { controller in
            guard let viewController = controller as? UIViewController else { fatalError() }
            viewController.title = LocalizableStrings.Insights.title()
            let rootController = UINavigationController(rootViewController: viewController)
            
            initialViewControllers.append(rootController)
        }
        
        let mainTabController = UITabBarController()
        mainTabController.viewControllers = initialViewControllers
        window?.rootViewController = mainTabController

        return true
    }
    
    private func configureServices() {
        serviceLocator = AppServiceLocator()

        CoreDataStackInitializer({ managedObjectContext in
            NSLog("Core Data Stack initialized correctly")
            
            self.serviceLocator.fitnessInfoRepository = CoreDataInfoRepository(managedObjectContext: managedObjectContext)
        }, { error in
            fatalError(error as! String)
        })
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        serviceLocator.viewControllerFactory = UIViewControllerFactory(storyboard: mainStoryboard)
    }
    
    private func configureRouting() {
        let allEntries = AppRouter.allEntries(serviceLocator: self.serviceLocator)
     
        serviceLocator.router = AppRouter(urlRouter: URLRouterFactory.with(entries: allEntries))
    }

}

extension AppDelegate {
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        switch shortcutItem.type {
        case "org.onset-bits.fitness-tracker.new-record": serviceLocator.router.open(appURL: URL(string: "app://records/new")!, resultHandler: { result in
            guard let viewController = result as? UIViewController else { fatalError() }
            
            self.window?.rootViewController?.show(viewController, sender: nil)
        })
            
        default: fatalError("Shortcut not handled")
        }
    }
}
