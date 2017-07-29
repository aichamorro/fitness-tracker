//
//  NewRecordInteractor.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 21/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias ICreateNewRecord = AnyInteractor<IFitnessInfo, IFitnessInfo>
final class CreateNewRecord: ICreateNewRecord {
    init(repository: IFitnessInfoRepository, healthKitRepository: IHealthKitRepository? = nil) {
        super.init { record -> Observable<IFitnessInfo> in
            return repository.rx_save(record).do(onNext: { saved in
                healthKitRepository?.save(height: saved.height,
                                          weight: saved.weight,
                                          bodyFatPercentage: saved.bodyFatPercentage,
                                          leanBodyMass: saved.leanBodyWeight,
                                          bmi: saved.bmi,
                                          date: saved.date as! Date)
            })
        }
    }
}
