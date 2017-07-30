//
//  CoreDataQueryRequest.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 04/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataQueryRequestLimit {
    case one
    case many(Int)
    case noLimit
}

enum CoreDataQueryRequestOrder {
    case ascendent
    case descendent

    var ascending: Bool {
        return self == .ascendent
    }
}

enum CoreDataEntity: String {
    case fitnessInfo = "FitnessInfo"
}

enum CoreDataQueryRequest {
    enum QueryType {
        case fetch
        case remove(object: NSManagedObject)
    }

    case findInterval(DateInterval, limit: CoreDataQueryRequestLimit, order: CoreDataQueryRequestOrder)
    case findAll(limit: CoreDataQueryRequestLimit, order: CoreDataQueryRequestOrder)
    case remove(record: CoreDataFitnessInfo)

    var type: QueryType {
        switch self {
        case .findInterval(_, _, _): fallthrough
        case .findAll(_, _):
            return .fetch

        case .remove(let managedObject):
            return .remove(object: managedObject)

        default:
            fatalError()
        }
    }
}

extension CoreDataQueryRequest {
    var fetchRequest: NSFetchRequest<NSFetchRequestResult>? {
        switch self {
        case .findAll(let limit, let order):
            let fetchRequest = findInDateIntervalFetchRequest(order: order)

            addLimitIfNeeded(limit, to: fetchRequest)

            return fetchRequest

        case .findInterval(let dateInterval, let limit, let order):
            let fetchRequest = findInDateIntervalFetchRequest(order: order)
            fetchRequest.predicate = findPredicate(with: dateInterval)

            addLimitIfNeeded(limit, to: fetchRequest)

            return fetchRequest

        case .remove(_):
            return nil
        }
    }

    private func findInDateIntervalFetchRequest(order: CoreDataQueryRequestOrder) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entity)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: order.ascending)]

        return fetchRequest
    }

    private func findPredicate(with dateInterval: DateInterval) -> NSPredicate {
        let predicateFormat = "((date >= %@) AND (date <= %@))"

        return NSPredicate(format: predicateFormat, dateInterval.start as CVarArg, dateInterval.end as CVarArg)
    }

    private func addLimitIfNeeded(_ limit: CoreDataQueryRequestLimit, to request: NSFetchRequest<NSFetchRequestResult>) {
        switch limit {
        case .one:
            request.fetchLimit = 1
        case .many(let resultsLimit):
            request.fetchLimit = resultsLimit
        default:
            break
        }
    }

    var entity: String {
        switch self {
        case .findAll: fallthrough
        case .remove(_): fallthrough
        case .findInterval:
            return CoreDataEntity.fitnessInfo.rawValue
        }
    }
}
