//
//  NewRecordInteractor.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 21/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol ICreateNewRecord {
    func rx_save(_ record: IFitnessInfo) -> Observable<IFitnessInfo>
}

final class CreateNewRecord: ICreateNewRecord {
    var repository: IFitnessInfoRepository
    var healthKitRepository: IHealthKitRepository?
    
    init(repository: IFitnessInfoRepository, healthKitRepository: IHealthKitRepository? = nil) {
        self.repository = repository
        self.healthKitRepository = healthKitRepository
    }
    
    func rx_save(_ record: IFitnessInfo) -> Observable<IFitnessInfo> {
        return repository.rx_save(record).do(onNext: { saved in
            self.healthKitRepository?.save(height: saved.height,
                                           weight: saved.weight,
                                           bodyFatPercentage: saved.bodyFatPercentage,
                                           leanBodyMass: saved.leanBodyWeight,
                                           bmi: saved.bmi,
                                           date: saved.date as! Date)
        })
    }
}
