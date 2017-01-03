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
    var mainStoryboard: UIStoryboard!
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
                
        serviceLocator.router.open(appURL: .showLatestRecord) { controller in
            guard let viewController = controller as? UIViewController else { fatalError() }
            viewController.title = NSLocalizedString("Last measurement", comment: "Last measurement")
            let rootController = UINavigationController(rootViewController: viewController)
            
            self.window?.rootViewController = rootController
        }

        // Override point for customization after application launch.
        return true
    }
    
    private func configureServices() {
        serviceLocator = AppServiceLocator()

        _ = CoreDataStackInitializer({ success in
            NSLog("Core Data Stack initialized correctly")
            
            self.serviceLocator.fitnessInfoRepository = CoreDataInfoRepository(managedObjectContext: success)
        }, { error in
            fatalError(error as! String)
        })
        
        serviceLocator.mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    }
    
    private func configureRouting() {
        let allEntries = AppRouterEntry.allEntries(serviceLocator: self.serviceLocator)
     
        serviceLocator.router = AppRouter(urlRouter: URLRouterFactory.with(entries: allEntries))
    }

}

