//
//  MVPView.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 07/07/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import UIKit

protocol MVPView: class {
    func dismiss()
    func push(_ wireframe: UIWireframe, animated: Bool)
    func presentModally(_ wireframe: UIWireframe, animated: Bool)
    func presentAsChild(_ wireframe: UIWireframe)
}

extension MVPView where Self: UIViewController {
    func push(_ wireframe: UIWireframe, animated: Bool = true) {
        guard let navigationController = self.navigationController else {
            fatalError("This controller is not part of a navigation stack")
        }

        wireframe.push(in: navigationController, animated: animated)
    }

    func presentModally(_ wireframe: UIWireframe, animated: Bool = true) {
        wireframe.presentModally(in: self, animated: animated)
    }

    func presentAsChild(_ wireframe: UIWireframe) {
        wireframe.presentAsChildController(in: self)
    }

    func dismiss() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else if self.presentationController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            fatalError("We don't know how to dismiss the view")
        }
    }
}
