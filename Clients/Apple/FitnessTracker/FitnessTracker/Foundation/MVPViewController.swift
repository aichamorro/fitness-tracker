//
//  MVPViewController.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 07/07/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import UIKit

class MVPViewController: UIViewController {
    var onViewDidLoad: (() -> Void)?
    var onResult: ((Any?) -> Void)?
    var retainBag: [Any]?
    var shouldHideNavigationBar: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad?()
        navigationController?.isNavigationBarHidden = shouldHideNavigationBar
    }
}
