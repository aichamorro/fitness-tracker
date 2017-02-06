//
//  FitnessInfoRepository.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 20/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

final class CoreDataInfoRepository: IFitnessInfoRepository {
    private let rx_updatedSubject = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    private let coreDataEngine: CoreDataEngine
    
    init(managedObjectContext: NSManagedObjectContext) {
        coreDataEngine = CoreDataEngine(managedObjectContext: managedObjectContext)
    }
    
    var rx_updated: Observable<Void> {
        return rx_updatedSubject.asObservable()
    }
    
    func rx_find(from: NSDate, to: NSDate, limit: CoreDataQueryRequestLimit, order: CoreDataQueryRequestOrder) -> Observable<[IFitnessInfo]> {
        let interval = DateInterval(start: from as Date, end: to as Date)
        let query = CoreDataQueryRequest.findInterval(interval, limit: limit, order: order)
        
        return coreDataEngine.rx_execute(query: query)
            .flatMap { return Observable.just($0 as! [IFitnessInfo]) }
    }
    
    func find(from: NSDate, to: NSDate, limit: CoreDataQueryRequestLimit, order: CoreDataQueryRequestOrder) -> [IFitnessInfo] {
        let interval = DateInterval(start: from as Date, end: to as Date)
        let query = CoreDataQueryRequest.findInterval(interval, limit: limit, order: order)
        
        return coreDataEngine.execute(query: query) as! [IFitnessInfo]
    }
    
    func rx_findLatest(numberOfRecords: Int) -> Observable<[IFitnessInfo]> {
        return coreDataEngine.rx_execute(query: .findAll(limit: .many(numberOfRecords), order: .descendent))
            .do(onNext: nil, onError: { NSLog("Error: \($0)") })
            .catchErrorJustReturn([])
            .flatMap { return Observable.just($0 as! [CoreDataFitnessInfo]) }
    }
    
    func findLatest(numberOfRecords: Int) -> [IFitnessInfo] {
        return coreDataEngine.execute(query: .findAll(limit: .many(numberOfRecords), order: .descendent)) as! [IFitnessInfo]
    }
    
    func rx_findAll() -> Observable<[IFitnessInfo]> {
        return coreDataEngine.rx_execute(query: .findAll(limit: .noLimit, order: .descendent))
            .flatMap { return Observable.just($0 as! [CoreDataFitnessInfo]) }
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
        
        rx_updatedSubject.onNext()
        
        return result
    }
    
}

