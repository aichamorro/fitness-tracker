//
//  CoreDataFitnessInfoRepository.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

final class CoreDataFitnessInfoRepository: IFitnessInfoRepository {

    enum Errors: Error {
        case InconsistencyError
    }

    private let rx_updatedSubject = PublishSubject<Void>()

    private let disposeBag = DisposeBag()
    private let coreDataEngine: CoreDataEngine

    init(coreDataEngine: CoreDataEngine) {
        self.coreDataEngine = coreDataEngine
    }

    var rx_updated: Observable<Void> {
        return rx_updatedSubject.asObservable()
    }

    func find(from: NSDate, to: NSDate, limit: CoreDataQueryRequestLimit, order: CoreDataQueryRequestOrder) -> [IFitnessInfo] {
        let interval = DateInterval(start: from as Date, end: to as Date)
        let query = CoreDataQueryRequest.findInterval(interval, limit: limit, order: order)

        do {
            return try coreDataEngine.execute(query: query) as! [IFitnessInfo]
        } catch {
            fatalError()
        }
    }

    func findLatest(numberOfRecords: Int) -> [IFitnessInfo] {
        do {
            return try coreDataEngine.execute(query: .findAll(limit: .many(numberOfRecords), order: .descendent)) as! [IFitnessInfo]
        } catch {
            fatalError()
        }
    }

    func findAll() -> [IFitnessInfo] {
        do {
            return try coreDataEngine.execute(query: .findAll(limit: .noLimit, order: .descendent)) as! [IFitnessInfo]
        } catch {
            fatalError()
        }
    }

    private func didUpdate() {
        rx_updatedSubject.onNext(())
    }

    @discardableResult func save(_ record: IFitnessInfo) throws -> IFitnessInfo {
        let result = try coreDataEngine.create(entityName: CoreDataEntity.fitnessInfo.rawValue, configuration: { entity in
            guard let saved = entity as? CoreDataFitnessInfo else { fatalError() }

            saved.height_ = Int16(record.height)
            saved.weight = record.weight
            saved.musclePercentage = record.musclePercentage
            saved.bodyFatPercentage = record.bodyFatPercentage
            saved.waterPercentage = record.waterPercentage
            saved.date = record.date ?? NSDate()
        }) as! IFitnessInfo

        didUpdate()

        return result
    }

    @discardableResult func remove(_ record: IFitnessInfo) throws -> IFitnessInfo? {
        guard let coreDataFitnessInfo = record as? CoreDataFitnessInfo else {
            throw Errors.InconsistencyError
        }

        let result = try coreDataEngine.execute(query: .remove(record: coreDataFitnessInfo)) as! IFitnessInfo?

        didUpdate()

        return result
    }
}
