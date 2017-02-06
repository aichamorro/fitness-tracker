//
//  IFitnessInfoRepository.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro on 04/02/2017.
//  Copyright © 2017 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift

protocol IFitnessInfoRepository {
    var rx_updated: Observable<Void> { get }
    
    func find(from: NSDate, to: NSDate, limit: CoreDataQueryRequestLimit, order: CoreDataQueryRequestOrder) -> [IFitnessInfo]
    func rx_find(from: NSDate, to: NSDate, limit: CoreDataQueryRequestLimit, order: CoreDataQueryRequestOrder) -> Observable<[IFitnessInfo]>
    
    func findLatest(numberOfRecords: Int) -> [IFitnessInfo]
    func rx_findLatest(numberOfRecords: Int) -> Observable<[IFitnessInfo]>
    
    func rx_findAll() -> Observable<[IFitnessInfo]>
    
    @discardableResult func save(record: IFitnessInfo) throws -> IFitnessInfo
    @discardableResult func rx_save(record: IFitnessInfo) -> Observable<IFitnessInfo>
}

extension IFitnessInfoRepository {
    func rx_save(record: IFitnessInfo) -> Observable<IFitnessInfo> {
        return Observable.create { observer -> Disposable in
            do {
                let saved = try self.save(record: record)
                
                observer.onNext(saved)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create { }
        }
    }
    
    func rx_find(from: NSDate, to: NSDate, order: CoreDataQueryRequestOrder) -> Observable<[IFitnessInfo]> {
        return rx_find(from: from, to: to, limit: .noLimit, order: order)
    }
    
    func find(from: NSDate, to: NSDate, order: CoreDataQueryRequestOrder) -> [IFitnessInfo] {
        return find(from: from, to: to, limit: .noLimit, order: order)
    }
}

extension IFitnessInfoRepository {
    func rx_findWeek(ofDay dayOfWeek: NSDate) -> Observable<[IFitnessInfo]> {
        let week = Calendar.current.weekInterval(of: dayOfWeek)!
        
        return rx_find(from: week.start as NSDate, to: week.end as NSDate, order: .ascendent)
    }
    
    func findFirstOfWeek(ofDay dayOfWeek: NSDate) -> IFitnessInfo? {
        let week = Calendar.current.weekInterval(of: dayOfWeek)!
        
        return find(from: week.start as NSDate, to: week.end as NSDate, limit: .one, order: .ascendent).first! as IFitnessInfo
    }
    
    func findFirstOfMonth(ofDay dayOfMonth: NSDate) -> IFitnessInfo? {
        let month = Calendar.current.monthInterval(of: dayOfMonth)!
        
        return find(from: month.start as NSDate, to: month.end as NSDate, limit: .one, order: .ascendent).first
    }
    
    func findFirstOfYear(ofDay dayOfYear: NSDate) -> IFitnessInfo? {
        let year = Calendar.current.yearInterval(of: dayOfYear)!
        
        return find(from: year.start as NSDate, to: year.end as NSDate, limit: .one, order: .ascendent).first
    }
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
