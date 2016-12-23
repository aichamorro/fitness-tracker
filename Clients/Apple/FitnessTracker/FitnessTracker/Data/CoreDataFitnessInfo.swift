//
//  CoreDataFitnessInfo.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 23/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataFitnessInfo: IFitnessInfo {
    public var height: UInt {
        return UInt(self.height_)
    }
}
