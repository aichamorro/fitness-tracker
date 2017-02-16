//
//  FindRecordsInInterval.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 08/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias DateRange = (Date, Date)
typealias IFindRecordsInInterval = AnyInteractor<DateRange, [IFitnessInfo]>
final class FindRecordsInInterval: IFindRecordsInInterval {
    init(repository: IFitnessInfoRepository) {
        super.init { from, to -> Observable<[IFitnessInfo]> in
            return repository.rx_find(from: from as NSDate,
                         to: to as NSDate,
                         order: .ascendent)
        }
    }
}
