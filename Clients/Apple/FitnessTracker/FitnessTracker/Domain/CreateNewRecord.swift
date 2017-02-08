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
    
    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }
    
    func rx_save(_ record: IFitnessInfo) -> Observable<IFitnessInfo> {
        return repository.rx_save(record)
    }
}
