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

protocol IFitnessInfoRepository {
    var rx_updated: Observable<Void> { get }
    
    func rx_findLatest(numberOfRecords: Int) -> Observable<[IFitnessInfo]>
    func rx_findAll() -> Observable<[IFitnessInfo]>
    
    func findFirstOfWeek(ofDay dayOfWeek: NSDate) -> IFitnessInfo?
    func findFirstOfMonth(ofDay dayOfMonth: NSDate) -> IFitnessInfo?
    func findFirstOfYear(ofDay dayOfYear: NSDate) -> IFitnessInfo?
    func findLatest(numberOfRecords: Int) -> [IFitnessInfo]
    
    @discardableResult func rx_save(record: IFitnessInfo) -> Observable<IFitnessInfo>
}

extension IFitnessInfoRepository {
    func rx_save(many records: [IFitnessInfo]) -> Observable<[IFitnessInfo]> {
        var result: [IFitnessInfo] = []
        var error: Error?
        let disposeBag = DisposeBag()
        
        for record in records {
            self.rx_save(record: record)
                .subscribe(onNext: { result.append($0) }, onError: { error = $0 } )
                .addDisposableTo(disposeBag)
        }
        
        return error != nil ? Observable.error(error!) : Observable.just(result)
    }
}

enum CoreDataEntity: String {
    case fitnessInfo = "FitnessInfo"
}

enum CoreDataQueryRequest {
    case findLatestRecords(limit: Int)
    case findLatest
    case findFirstRecordOfWeek(date: NSDate)
    case findFirstRecordOfMonth(date: NSDate)
    case findFirstRecordOfYear(date: NSDate)
    case findAll
}

extension CoreDataQueryRequest {
    var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
        switch self {
        case .findLatest:
            return CoreDataQueryRequest.findLatestRecords(limit: 1).fetchRequest
            
        case .findLatestRecords(let limit):
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entity)
            fetchRequest.fetchLimit = limit
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            return fetchRequest
            
        case .findFirstRecordOfWeek(let date):
            let startDate = Calendar.current.previousMonday(fromDate: date)
            let dateInterval = DateInterval(start: startDate as Date, duration: SEC_PER_WEEK)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entity)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "((date >= %@) AND (date <= %@))", dateInterval.start as CVarArg, dateInterval.end as CVarArg)
            
            return fetchRequest
            
        case .findFirstRecordOfMonth(let date):
            let dateInterval = Calendar.current.monthInterval(of: date)!
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entity)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "((date >= %@) AND (date < %@))", dateInterval.start as CVarArg, dateInterval.end as CVarArg)
            
            return fetchRequest
            
        case .findFirstRecordOfYear(let date):
            let dateInterval = Calendar.current.yearInterval(of: date)!
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entity)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "((date >= %@) AND (date < %@))", dateInterval.start as CVarArg, dateInterval.end as CVarArg)
            
            return fetchRequest
            
        case .findAll:
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entity)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            return fetchRequest
        }
    }
    
    var entity: String {
        switch self {
        case .findFirstRecordOfWeek(_): fallthrough
        case .findLatest: fallthrough
        case .findAll: fallthrough
        case .findFirstRecordOfMonth(_): fallthrough
        case .findFirstRecordOfYear(_): fallthrough
        case .findLatestRecords(_):
            return CoreDataEntity.fitnessInfo.rawValue
        }
    }
}

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
    
    func rx_findLatest(numberOfRecords: Int) -> Observable<[IFitnessInfo]> {
        return coreDataEngine.rx_execute(query: .findLatestRecords(limit: numberOfRecords))
            .do(onNext: nil, onError: { NSLog("Error: \($0)") })
            .catchErrorJustReturn([])
            .flatMap { return Observable.just($0 as! [CoreDataFitnessInfo]) }
    }
    
    func findLatest(numberOfRecords: Int) -> [IFitnessInfo] {
        return coreDataEngine.execute(query: .findLatestRecords(limit: numberOfRecords)) as! [IFitnessInfo]
    }
    
    func rx_findAll() -> Observable<[IFitnessInfo]> {
        return coreDataEngine.rx_execute(query: .findAll)
            .flatMap { return Observable.just($0 as! [CoreDataFitnessInfo]) }
    }
    
    func findFirstOfWeek(ofDay dayOfWeek: NSDate) -> IFitnessInfo? {
        return coreDataEngine.execute(query: .findFirstRecordOfWeek(date: dayOfWeek)).first as! IFitnessInfo?
    }
    
    func findFirstOfMonth(ofDay dayOfMonth: NSDate) -> IFitnessInfo? {
        return coreDataEngine.execute(query: .findFirstRecordOfMonth(date: dayOfMonth)).first as! IFitnessInfo?
    }
    
    func findFirstOfYear(ofDay dayOfYear: NSDate) -> IFitnessInfo? {
        return coreDataEngine.execute(query: .findFirstRecordOfYear(date: dayOfYear)).first as! IFitnessInfo?
    }
    
    @discardableResult func rx_save(record: IFitnessInfo) -> Observable<IFitnessInfo> {
        return coreDataEngine.create(entityName: CoreDataEntity.fitnessInfo.rawValue) { entity in
            guard let saved = entity as? CoreDataFitnessInfo else { fatalError() }
            
            saved.height_ = Int16(record.height)
            saved.weight = record.weight
            saved.musclePercentage = record.musclePercentage
            saved.bodyFatPercentage = record.bodyFatPercentage
            saved.waterPercentage = record.waterPercentage
            saved.date = NSDate()
        }.do(onNext: { [weak self] _ in
            self?.rx_updatedSubject.onNext()
        }).flatMap {
            return Observable.just($0 as! IFitnessInfo)
        }
    }
}

