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
}

public extension Resolver {
    func autoResolve<T>() -> T {
        resolve(T.self)!
    }
}
