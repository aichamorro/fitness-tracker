//
//  UIWireframe.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 07/07/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import UIKit
import RxCocoa

struct UIWireframe {
    let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    init(viewController: MVPViewController, _ onViewDidLoad: (() -> Void)?) {
        self.viewController = viewController
        viewController.onViewDidLoad = onViewDidLoad
    }

    func presentModally(in rootController: UIViewController, animated: Bool) {
        rootController.present(viewController, animated: animated, completion: {})
    }

    func push(in controller: UINavigationController, animated: Bool = true) {
        controller.pushViewController(viewController, animated: animated)
    }

    func replaceRoot() {
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }

    func embeddedInNavigationController() -> UIWireframe {
        let navigationController = UINavigationController(rootViewController: viewController)

        return UIWireframe(viewController: navigationController)
    }

    func presentAsChildController(in parent: UIViewController) {
        parent.addChildViewController(viewController)
        parent.view.addSubview(viewController.view)
        parent.didMove(toParentViewController: parent)
    }
}
