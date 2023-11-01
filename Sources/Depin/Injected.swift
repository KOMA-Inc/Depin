import Swinject

@propertyWrapper
public final class Injected<Service> {

    @Space(\.dependenciesContainer)
    private var dependenciesContainer: Container

    private let serviceName: ServiceName?

    private lazy var value = dependenciesContainer
        .synchronize()
        .resolve(Service.self, name: serviceName?.name)!

    public var wrappedValue: Service {
        value
    }

    public init(_ serviceName: ServiceName? = nil) {
        self.serviceName = serviceName
    }
}
