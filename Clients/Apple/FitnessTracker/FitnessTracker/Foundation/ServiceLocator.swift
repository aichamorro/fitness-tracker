//
//  ServiceLocator.swift
//  FitnessTracker
//
// https://gist.githubusercontent.com/FGoessler/2b7df61ab3fb81048de3/raw/68a620d585b2b8984522717587a38a1ad7f06bb5/ServiceLocator.swift
//
//

import Foundation

public protocol ServiceLocatorModule {
    func registerServices(serviceLocator: ServiceLocator)
}

public class ServiceLocator {
    private var registry = [ObjectIdentifier: Any]()

    public static var shared = ServiceLocator()

    private init() {
        registerModules(modules: [DefaultServices()])
    }

    static func configure() {
        _ = ServiceLocator.shared
    }

    // MARK: Registration

    public func registerFactory<Service>(factory: @escaping () -> Service) {
        let serviceId = ObjectIdentifier(Service.self)
        registry[serviceId] = factory
    }

    public static func registerFactory<Service>(_ factory: @escaping () -> Service) {
        ServiceLocator.shared.registerFactory(factory: factory)
    }

    public func registerSingleton<Service>(_ singletonInstance: Service) {
        let serviceId = ObjectIdentifier(Service.self)
        registry[serviceId] = singletonInstance
    }

    public static func registerSingleton<Service>(_ singletonInstance: Service) {
        ServiceLocator.shared.registerSingleton(singletonInstance)
    }

    public func registerModules(modules: [ServiceLocatorModule]) {
        modules.forEach { $0.registerServices(serviceLocator: self) }
    }

    public static func registerModules(_ modules: [ServiceLocatorModule]) {
        shared.registerModules(modules: modules)
    }

    // MARK: Injection

    public static func inject<Service>() -> Service {
        return ServiceLocator.shared.inject()
    }

    // This method is private because no service which wants to request other services should
    // bind itself to specific instance of a service locator.
    private func inject<Service>() -> Service {
        let serviceId = ObjectIdentifier(Service.self)
        if let factory = registry[serviceId] as? () -> Service {
            return factory()
        } else if let singletonInstance = registry[serviceId] as? Service {
            return singletonInstance
        } else {
            fatalError("No registered entry for \(Service.self)")
        }
    }
}

extension ServiceLocator {
    static func registerCoreDataRepositories() {
        ServiceLocator.registerModules([DefaultRepositories()])
    }
}

private class DefaultServices: ServiceLocatorModule {
    func registerServices(serviceLocator: ServiceLocator) {
        serviceLocator.registerSingleton(DefaultAppRouter() as AppRouter)
        serviceLocator.registerSingleton(UIViewControllerFactory() as IUIViewControllerFactory)
    }
}

private class DefaultRepositories: ServiceLocatorModule {
    func registerServices(serviceLocator: ServiceLocator) {
        let coreDataEngine: CoreDataEngine = ServiceLocator.inject()

        serviceLocator.registerSingleton(CoreDataFitnessInfoRepository(coreDataEngine: coreDataEngine) as IFitnessInfoRepository)

        if let healthKitRepository = HealthKitRepository() {
            serviceLocator.registerSingleton(healthKitRepository as IHealthKitRepository)
        } else {
            NSLog("Warning: Couldn't initialize HealthKitRepository, using a dummy one")
            serviceLocator.registerSingleton(DummyHealthKitRepository() as IHealthKitRepository)
        }
    }
}
