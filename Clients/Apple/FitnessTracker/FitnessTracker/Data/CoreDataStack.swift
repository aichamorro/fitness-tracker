//
//  CoreDataStack.swift
//  FitnessTracker
//
//  Created by Alberto Chamorro - Personal on 23/12/2016.
//  Copyright © 2016 OnsetBits. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

typealias ICoreDataStackInitializer = () -> Observable<NSManagedObjectContext>
internal let CoreDataStackInitializer: ICoreDataStackInitializer = {
    let modelURL: () -> Observable<URL> = {
        return Observable.create { observer in
            guard let modelURL = Bundle.main.url(forResource: "CoreDataModel", withExtension: "momd") else {
                observer.onError(NSError(domain: "Core Data", code: -1, userInfo: nil))
                
                return Disposables.create()
            }
            
            observer.onNext(modelURL)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    let mom: (URL) -> Observable<NSManagedObjectModel> = { url in
        return Observable.create { observer in
            guard let mom = NSManagedObjectModel(contentsOf: url) else {
                observer.onError(NSError(domain: "Core Data", code: -1, userInfo: nil))
                
                return Disposables.create()
            }
            
            observer.onNext(mom)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    let managedObjectContext: (NSManagedObjectModel) -> Observable<NSManagedObjectContext> = { mom in
        return Observable.create { observer in
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            managedObjectContext.persistentStoreCoordinator = psc
            
            observer.onNext(managedObjectContext)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    let initializePSC: (NSManagedObjectContext) -> Void = { moc in
        DispatchQueue.global(qos: .background).async {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex - 1]
            let storeURL = docURL.appendingPathComponent("FitnessTrackerDataModel.sqlite")
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            
            do {
                let psc = moc.persistentStoreCoordinator!
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    return modelURL()
        .flatMap(mom)
        .flatMap(managedObjectContext)
        .do(onNext: { initializePSC($0) })
}

struct CoreDataEngine {
    let managedObjectContext: NSManagedObjectContext
    
    func execute(query: CoreDataQueryRequest) -> Observable<[Any]> {
        return Observable.create { observer in
            do {
                let result = try self.managedObjectContext.fetch(query.fetchRequest)
                
                observer.onNext(result)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create {
                observer.onCompleted()
            }
        }
    }
    
    func create(entityName: String, configuration: ((NSManagedObject) -> Void)?) -> Observable<NSManagedObject> {
        let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext)
        
        configuration?(newObject)
        
        do {
            try managedObjectContext.save()
            
            return Observable.just(newObject)
        } catch {
            return Observable
                .error(NSError(domain: "Core Data", code: -1, userInfo: nil))
                .do(onNext: nil, onError: { error in NSLog("Failure when saving the context: \(error)") })
        }
    }
}

