
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Alberto Chamorro on 23/01/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import UIKit
import NotificationCenter
//import FitnessTracker

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet private var heightLabel: UILabel!
    @IBOutlet private var weightLabel: UILabel!
    @IBOutlet private var bodyFatWeightLabel: UILabel!
    @IBOutlet private var muscleWeightLabel: UILabel!
    @IBOutlet private var waterPercentageLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
//        let fitnessInfo = FitnessInfo(weight: 0, height: 0, bodyFatPercentage: 0, musclePercentage: 0, waterPercentage: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

//extension TodayViewController: ILatestRecordView {
//    
//}
