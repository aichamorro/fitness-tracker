//
//  NewRecordView.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 21/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol INewRecordView: class {
    var height: UInt { get set }
    var weight: Double { get set }
    var bodyFatPercentage: Double { get set }
    var musclePercentage: Double { get set }
    var waterPercentage: Double { get set }
    
    var rx_viewDidLoad: Observable<Void> { get }
    var rx_actionSave: Observable<NewRecordViewModel> { get }
    var calibrationFix: Double { get }
    
    func dismiss()
}
