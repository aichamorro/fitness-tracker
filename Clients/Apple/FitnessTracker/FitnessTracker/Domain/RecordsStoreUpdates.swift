//
//  RecordsStoreUpdates.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 08/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IRecordStoreUpdate {
    var rx_didUpdate: Observable<Void> { get }
}

final class RecordStoreUpdate: IRecordStoreUpdate {
    private let repository: IFitnessInfoRepository

    init(repository: IFitnessInfoRepository) {
        self.repository = repository
    }

    var rx_didUpdate: Observable<Void> {
        return repository.rx_updated
    }
}
