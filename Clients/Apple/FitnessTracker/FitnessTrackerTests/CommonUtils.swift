//
//  CommonUtils.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 21/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift
import RxTest
import Quick
import Nimble
import CoreData

func createObserverAndSubscribe<T>(to observable: Observable<T>, scheduler: TestScheduler, disposeBag: DisposeBag, expect: ((T) -> Void)?, action: @escaping (()->Void)) {
    let observer = scheduler.createObserver(T.self)
    var didFinish: Bool = false
    
    waitUntil { done in
        observable.subscribe(onNext: {_ in
            didFinish = true
            done()
        }).addDisposableTo(disposeBag)
        
        observable.subscribe(observer).addDisposableTo(disposeBag)
        action()
    }
    
    guard didFinish else { return }
    if T.self != Void.self {
        let actual = observer.events.first!.value.element!
        
        expect?(actual)
    }    
}

let SetUpInMemoryManagedObjectContext: () -> NSManagedObjectContext = {
    let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    
    do {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    } catch {
        fatalError("Couldn't initialize an in-memory data stack")
    }
    
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedObjectContext
}

extension Calendar {
    func date(withDay day: Int, month: Int, year: Int, hour: Int, minute: Int) -> Date? {
        return DateComponents(calendar: Calendar.current,
                                        timeZone: TimeZone(identifier: "Europe/London"),
                                        year: year,
                                        month: month,
                                        day: day,
                                        hour: hour,
                                        minute: minute).date
    }
}
