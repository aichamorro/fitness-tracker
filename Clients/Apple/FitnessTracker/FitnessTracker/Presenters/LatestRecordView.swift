//
//  LatestRecordView.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

struct LatestRecordViewModel {
    let weight: Double
    let height: UInt
    let bodyFat: Double
    let muscle: Double
    let water: Double
    let bodyFatWeight: Double
    let muscleWeight: Double
    let waterWeight: Double
    let leanBodyWeight: Double
    let bmi: Double
}

extension LatestRecordViewModel {
    static var empty: LatestRecordViewModel = {
        return LatestRecordViewModel(weight: 0,
                                   height: 0,
                                   bodyFat: 0,
                                   muscle: 0,
                                   water: 0,
                                   bodyFatWeight: 0,
                                   muscleWeight: 0,
                                   waterWeight: 0,
                                   leanBodyWeight: 0,
                                   bmi: 0)
    }()

    static func from(fitnessInfo: IFitnessInfo) -> LatestRecordViewModel {
        return LatestRecordViewModel(weight: fitnessInfo.weight,
                                   height: fitnessInfo.height,
                                   bodyFat: fitnessInfo.bodyFatPercentage,
                                   muscle: fitnessInfo.musclePercentage,
                                   water: fitnessInfo.waterPercentage,
                                   bodyFatWeight: fitnessInfo.bodyFatWeight,
                                   muscleWeight: fitnessInfo.muscleWeight,
                                   waterWeight: fitnessInfo.waterWeight,
                                   leanBodyWeight: fitnessInfo.leanBodyWeight,
                                   bmi: fitnessInfo.bmi)
    }
}

protocol ILatestRecordView: class {
    var viewModel: LatestRecordViewModel { get set }
    var rx_viewDidLoad: Observable<Void> { get }
    var rx_didSelectMetric: Observable<BodyMetric> { get }

    func viewDidLoad()
}

extension ILatestRecordView {
    var rx_viewModel: AnyObserver<LatestRecordViewModel> {
        return AnyObserver { event in
            switch event {
            case .next(let element): self.viewModel = element
            default: break
            }
        }
    }
}
