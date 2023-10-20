import Swinject

infix operator ~>

func ~><Service>(container: Container, type: Service.Type) -> Service {
    container.resolve(type)!
}

func ~><Service>(container: Container, data: (type: Service.Type, name: String?)) -> Service {
    container.resolve(data.type, name: data.name)!
}

func ~><Service>(resolver: Resolver, type: Service.Type) -> Service {
    resolver.resolve(type)!
}
