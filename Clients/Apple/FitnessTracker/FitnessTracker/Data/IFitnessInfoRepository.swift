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
    func findLatest(numberOfRecords: Int) -> [IFitnessInfo]
    func findAll() -> [IFitnessInfo]

    @discardableResult func save(_ record: IFitnessInfo) throws -> IFitnessInfo
    @discardableResult func remove(_ record: IFitnessInfo) throws -> IFitnessInfo?
}

extension IFitnessInfoRepository {
    func find(from: NSDate, to: NSDate, order: CoreDataQueryRequestOrder) -> [IFitnessInfo] {
        return find(from: from, to: to, limit: .noLimit, order: order)
    }
}

extension IFitnessInfoRepository {
    func rx_find(from: NSDate, to: NSDate, order: CoreDataQueryRequestOrder) -> Observable<[IFitnessInfo]> {
        return rx_find(from: from, to: to, limit: .noLimit, order: order)
    }

    func rx_find(from: NSDate, to: NSDate, limit: CoreDataQueryRequestLimit, order: CoreDataQueryRequestOrder) -> Observable<[IFitnessInfo]> {
        return Observable.create { observer in
            let found = self.find(from: from, to: to, limit: limit, order: order)
            observer.onNext(found)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func rx_save(_ record: IFitnessInfo) -> Observable<IFitnessInfo> {
        return Observable.create { observer -> Disposable in
            do {
                let saved = try self.save(record)

                observer.onNext(saved)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    func rx_findLatest(numberOfRecords: Int) -> Observable<[IFitnessInfo]> {
        return Observable.create { observer in
            let found = self.findLatest(numberOfRecords: numberOfRecords)
            observer.onNext(found)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func rx_findAll() -> Observable<[IFitnessInfo]> {
        return Observable.create { observer in
            let found = self.findAll()
            observer.onNext(found)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func rx_remove(_ record: IFitnessInfo) -> Observable<IFitnessInfo?> {
        return Observable.create { observer in
            do {
                let removed = try self.remove(record)
                observer.onNext(removed)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
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
            self.rx_save(record)
                .subscribe(onNext: { result.append($0) }, onError: { error = $0 })
                .disposed(by: disposeBag)
        }

        return error != nil ? Observable.error(error!) : Observable.just(result)
    }
}
