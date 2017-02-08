//
//  FindRecordsInInterval.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 08/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IFindRecordsInInterval {
    func find(from: Date, to: Date) -> Observable<[IFitnessInfo]>
}

extension IFindRecordsInInterval {
    func find(from: Date) -> Observable<[IFitnessInfo]> {
        return self.find(from: from, to: Calendar.current.endOfToday)
    }
}
