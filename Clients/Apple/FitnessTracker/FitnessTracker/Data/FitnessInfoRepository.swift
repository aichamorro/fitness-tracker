//
//  FitnessInfoRepository.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation

protocol IFitnessInfoRepository {
    func getLastRecord(success: (IFitnessInfo) -> Void, error: (Error) -> Void)
}
