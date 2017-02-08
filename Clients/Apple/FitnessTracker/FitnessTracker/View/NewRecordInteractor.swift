//
//  NewRecordInteractor.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 21/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol INewRecordInteractor {
    func rx_save(record: IFitnessInfo) -> Observable<IFitnessInfo>
}

final class NewRecordInteractor: INewRecordInteractor {
    var repository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }
    
    func rx_save(record: IFitnessInfo) -> Observable<IFitnessInfo> {
        return repository.rx_save(record)
    }
}
