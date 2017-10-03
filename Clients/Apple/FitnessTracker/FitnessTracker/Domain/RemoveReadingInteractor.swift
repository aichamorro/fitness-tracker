//
//  RemoveReadingInteractor.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 05/08/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

typealias RemoveReadingInteractor = AnyInteractor<IFitnessInfo, IFitnessInfo?>

class RemoveReadingInteractorImpl: RemoveReadingInteractor {
    init(repository: IFitnessInfoRepository) {
        super.init { record -> Observable<IFitnessInfo?> in
            return repository.rx_remove(record)
        }

    }
}
