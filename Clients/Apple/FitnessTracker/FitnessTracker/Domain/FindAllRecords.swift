//
//  FindAllRecords.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 08/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias IFindAllRecords = AnyInteractor<Void, [IFitnessInfo]>

final class FindAllRecords: IFindAllRecords {
    init(repository: IFitnessInfoRepository) {
        super.init { () -> Observable<[IFitnessInfo]> in
            return repository.rx_findAll()
        }
    }
}
