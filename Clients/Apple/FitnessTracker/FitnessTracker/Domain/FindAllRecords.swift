//
//  FindAllRecords.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 08/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IFindAllRecords {
    func rx_findAll() -> Observable<[IFitnessInfo]>
}

final class FindAllRecords: IFindAllRecords {
    let repository: IFitnessInfoRepository
    
    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }
    
    func rx_findAll() -> Observable<[IFitnessInfo]> {
        return repository.rx_findAll()
    }
}
