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

typealias ICoreDataStackInitializerSuccess = (NSManagedObjectContext) -> Void
typealias ICoreDataStackInitializerError = (Error) -> Void
typealias ICoreDataStackInitializer = (@escaping ICoreDataStackInitializerSuccess, @escaping ICoreDataStackInitializerError) -> Void
typealias IRxCoreDataStackInitializer = () -> Observable<NSManagedObjectContext?>

internal let CoreDataStackInitializer: ICoreDataStackInitializer = { success, error in
    let modelURL: () -> URL? = {
        guard let modelURL = Bundle.main.url(forResource: "CoreDataModel", withExtension: "momd") else {
            error(NSError(domain: "Core Data", code: -1, userInfo: nil))
            
            return nil
        }
        
        return modelURL
    }
    
    let mom: (URL) -> NSManagedObjectModel? = { url in
        guard let mom = NSManagedObjectModel(contentsOf: url) else {
            error(NSError(domain: "Core Data", code: -1, userInfo: nil))
            
            return nil
        }
        
        return mom
    }
    
    let managedObjectContext: (NSManagedObjectModel) -> NSManagedObjectContext = { mom in
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext.persistentStoreCoordinator = psc

        return managedObjectContext
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
    
    guard let url = modelURL(), let managedObjectModel = mom(url) else {
            return
    }
    
    let moc = managedObjectContext(managedObjectModel)
    initializePSC(moc)
    
    success(moc)
}

internal let RxCoreDataStackInitializer: IRxCoreDataStackInitializer = {
    return Observable.create { observer in
        CoreDataStackInitializer({ moc in
                observer.onNext(moc)
                observer.onCompleted()
            }, { error in
                observer.onError(error)
            })
        
        return Disposables.create() {}
    }
}

struct CoreDataEngine {
    let managedObjectContext: NSManagedObjectContext
    
    func execute(query: CoreDataQueryRequest) -> [Any] {
        do {
            return try self.managedObjectContext.fetch(query.fetchRequest)
        } catch {
            fatalError()
        }
    }
    
    func rx_execute(query: CoreDataQueryRequest) -> Observable<[Any]> {
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

