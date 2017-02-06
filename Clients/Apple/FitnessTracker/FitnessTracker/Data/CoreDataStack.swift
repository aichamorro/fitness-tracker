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
    let databaseFilename = "FitnessTrackerDataModel.sqlite"
    let containerPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.org.onset-bits.fitness-tracker")
    var storeURL = containerPath!.appendingPathComponent(databaseFilename)
    
    func modelURL() -> URL? {
        guard let modelURL = Bundle.main.url(forResource: "CoreDataModel", withExtension: "momd") else {
            error(NSError(domain: "Core Data", code: -1, userInfo: nil))
            
            return nil
        }
        
        return modelURL
    }
    func mom(url: URL) -> NSManagedObjectModel? {
        guard let mom = NSManagedObjectModel(contentsOf: url) else {
            error(NSError(domain: "Core Data", code: -1, userInfo: nil))
            
            return nil
        }
        
        return mom
    }
    func managedObjectContext(mom: NSManagedObjectModel) -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext.persistentStoreCoordinator = psc

        return managedObjectContext
    }
    func initializePSC(moc: NSManagedObjectContext) -> Void {
        func needsMigration() -> Bool {
            if FileManager.default.fileExists(atPath: storeURL.path) {
                return false
            }
            
            return true
        }

        DispatchQueue.global(qos: .background).async {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            
            do {
                let psc = moc.persistentStoreCoordinator!
                
                if needsMigration() {
                    // TODO: Copy the database
                    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let docURL = urls[urls.endIndex - 1]
                    let oldStoreURL = docURL.appendingPathComponent(databaseFilename)
                    
                    do {
                        try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: oldStoreURL, options: options)
                        try psc.migratePersistentStore(psc.persistentStore(for: oldStoreURL)!, to: storeURL, options: options, withType: NSSQLiteStoreType)
                    } catch {
                        fatalError()
                    }
                } else {
                    try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
                }
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    // MARK: CoreData initialization
    guard let url = modelURL(), let managedObjectModel = mom(url: url) else {
            return
    }
    
    let moc = managedObjectContext(mom: managedObjectModel)
    initializePSC(moc: moc)
    
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
    
    func create(entityName: String, configuration: ((NSManagedObject) -> Void)?) throws -> NSManagedObject {
        let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext)
        
        configuration?(newObject)
        
        try managedObjectContext.save()

        return newObject
    }
}

