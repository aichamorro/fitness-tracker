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
    init(infoRepository: IFitnessInfoRepository) {
        super.init { record -> Observable<IFitnessInfo?> in
            return infoRepository.rx_remove(record)
        }

    }
}
