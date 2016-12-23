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
    var rx_latest: Observable<IFitnessInfo> { get }
    
    func loadLatest()
    func save(record: IFitnessInfo) -> Observable<IFitnessInfo>
}

class CoreDataInfoRepository: IFitnessInfoRepository {
    let rx_latestSubject = PublishSubject<IFitnessInfo>()
    private var managedObjectContext: NSManagedObjectContext!
    let disposeBag = DisposeBag()
    
    init() {
        CoreDataStackInitializer()
            .do(onNext: { _ in NSLog("Core Data Stack initialized correctly")},
                onError: { error in NSLog("Failure while initializing Core Data Stack: \(error)") })
            .subscribe(onNext: { self.managedObjectContext = $0 }, onError: { _ in fatalError() })
            .addDisposableTo(disposeBag)
    }
    
    var rx_latest: Observable<IFitnessInfo> {
        return rx_latestSubject.asObservable()
    }
    
    func loadLatest() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FitnessInfo")
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        var latestRecord: IFitnessInfo = FitnessInfo(weight: 0, height: 0, bodyFatPercentage: 0, musclePercentage: 0)
        do {
            let result = try managedObjectContext.fetch(fetchRequest) as! [CoreDataFitnessInfo]
            
            latestRecord = result.first ?? latestRecord
        } catch {
            fatalError("Couldn't fetch the store records")
        }
        
        rx_latestSubject.onNext(latestRecord)
    }
    
    func save(record: IFitnessInfo) -> Observable<IFitnessInfo> {
        let saved = NSEntityDescription.insertNewObject(forEntityName: "FitnessInfo", into: managedObjectContext) as! CoreDataFitnessInfo
        
        saved.height_ = Int16(record.height)
        saved.weight = record.weight
        saved.musclePercentage = record.musclePercentage
        saved.bodyFatPercentage = record.bodyFatPercentage
        saved.date = NSDate()
        
        do {
            try managedObjectContext.save()
        } catch {
            return Observable
                .error(NSError(domain: "Core Data", code: -1, userInfo: nil))
                .do(onNext: nil, onError: { error in NSLog("Failure when saving the context: \(error)") })
        }
        
        rx_latestSubject.onNext(saved)

        return Observable.just(saved)
    }
}

class MockFitnessInfoRepository: IFitnessInfoRepository {
    
    private let rx_latestSubject = PublishSubject<IFitnessInfo>()
    
    var mockLastRecord: IFitnessInfo!

    init(mockLastRecord: IFitnessInfo) {
        self.mockLastRecord = mockLastRecord
    }
    
    var rx_latest: Observable<IFitnessInfo> {
        return rx_latestSubject.asObservable()
    }
    
    func loadLatest() {
        rx_latestSubject.onNext(mockLastRecord)
    }
    
    func save(record: IFitnessInfo) -> Observable<IFitnessInfo> {
        mockLastRecord = record
     
        return Observable.just(mockLastRecord)
    }
}

