import Swinject

infix operator ~>

public func ~><Service>(container: Container, type: Service.Type) -> Service {
    container.resolve(type)!
}

public func ~><Service>(container: Container, data: (type: Service.Type, name: String?)) -> Service {
    container.resolve(data.type, name: data.name)!
}

public func ~><Service>(resolver: Resolver, type: Service.Type) -> Service {
    resolver.resolve(type)!
}

public extension Container {
    func autoResolve<T>() -> T {
        resolve(T.self)!
    }

    /// Adds a registration for the specified service with the factory closure to specify how the service is
    /// resolved with dependencies.
    ///
    /// - Parameters:
    ///   - serviceType: The service type to register.
    ///   - name:        A registration name, which is used to differentiate from other registrations
    ///                  that have the same service and factory types.
    ///   - factory:     The closure to specify how the service type is resolved with the dependencies of the type.
    ///                  It is invoked when the ``Container`` needs to instantiate the instance.
    ///                  It takes a ``Resolver`` to inject dependencies to the instance,
    ///                  and returns the instance of the component type for the service.
    ///
    /// - Returns: A registered ``ServiceEntry`` to configure more settings with method chaining.
    @discardableResult
   func register<Service>(
        _ serviceType: Service.Type,
        name: String? = nil,
        factory: @escaping () -> Service
    ) -> ServiceEntry<Service> {
        _register(serviceType, factory:  { (_: Resolver) in factory() }, name: name)
    }
}

public extension Resolver {
    func autoResolve<T>() -> T {
        resolve(T.self)!
    }
}
