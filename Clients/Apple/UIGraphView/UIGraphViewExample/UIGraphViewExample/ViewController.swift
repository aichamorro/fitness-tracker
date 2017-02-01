//
//  ViewController.swift
//  UIGraphViewExample
//
//  Created by Alberto Chamorro on 28/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import UIKit
import UIGraphView

class ViewController: UIViewController {
    
    @IBOutlet var graph: UIGraphView!
    @IBOutlet var graphTitle: UILabel!
    @IBOutlet var graphSubtitle: UILabel!

    fileprivate let weekWeights = [68.28, 67.98, 67.98, 67.51, 68.02, 67.68, 67.47]
    fileprivate let weekWeightsRocio = [16.03, 15.95, 16.21, 15.97, 15.98, 15.86, 15.49]
    fileprivate let weekDays = Array(22...28).map { Double($0) }
    
    var shouldUpdateHeaderHeight = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        graph.delegate = self
        graph.datasource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: UIGraphViewDataSource, UIGraphViewDelegate {
    func data(for dispersionGraph: UIGraphView) -> UIGraphViewSampleData {
        return UIGraphViewSampleData(weekDays, weekWeightsRocio)
    }
}
