# Depin
Depin is a library for dependency injection based on [Swinject](https://github.com/Swinject/Swinject) but with some additional wrapping logic.  

The overall approach is like this: register dependencies on app launch, then simply use them.  

## Register dependencies 
You should register dependencies as soon as possible in your app. Here is an example:
```swift
import Depin
import UIKit

@main
enum Main {

    @Space(\.dependenciesAssembler)
    private static var assembler: Assembler

    static func main() {

        assembler.apply(assemblies: [
            // ...
        ])

        UIApplicationMain(
            CommandLine.argc,
            CommandLine.unsafeArgv,
            nil,
            NSStringFromClass(AppDelegate.self)
        )
    }
}
```
Here you retrieve a Swinject's `Assembler` from `Space` (it is an analog for SwiftUI's `Environment`). After that, you should pass an array of assemblies, each of which contains logic for dependencies' registration. For example:
```swift
import Depin

class AppAssembly: Assembly {
    
    func assemble(container: Swinject.Container) {
        
        container.register(ModuleBuilder.self) {
            ModuleBuilder()
        }

        container.registerSynchronized(ApplicationLifeCycleCompositor.self) { r in
            ApplicationLifeCycleCompositor(delegates: [
                r ~> AnalyticClientCompositor.self,
                r ~> LifecycleHandler.self
            ])
        }
    }
}
```

`Assembler` from the first example has a property `Container`, which is used in assemblies to register dependencies. The same `Container` is later used to retrieve them.
You will register dependencies in either of two ways:  
1. Use this function if the dependency has no dependencies that must be passed in `init`, as with `ModuleBuilder` case
```swift
register<Service>(
        _ serviceType: Service.Type,
        name: String? = nil,
        factory: @escaping () -> Service
    )
```
2. Use this function if the dependency has dependencies that must be passed in `init`, as with `ApplicationLifeCycleCompositor` case
```swift
registerSynchronized<Service>(
        _ serviceType: Service.Type,
        name: String? = nil,
        factory: @escaping (Resolver) -> Service
    )
```

## Revtriving dependencies

To retrieve the dependency, simply use `@Injected` property wrapper
```swift
class FeedbackFormViewStateFactory {

    @Injected private var i18n: I18n

    // ...
}
```

## Register as singleton
When you register a dependency, you pass a closure that should create an instance of this dependency. Meaning, that if different classes has the same dependency, you will get different instances of it. If you need a singleton behavior, register the dependency like this:
```swift
container.register(Test.self) {
    Test()
}
.inObjectScope(.container)
```

## Register the same dependency with different names
What if you need several different singleton-like instances? You should register it with `name`. Here is an approach you can use to avoid using string:
1. Create a enum with services types an conform it to `ServiceName`
```swift
import Depin

enum DepinServiceType: String {
    case test
}

extension DepinServiceType: ServiceName {
    var name: String {
        rawValue
    }
}

```
2. Create an extension for `Container` in your app
```swift
import Depin

extension Container {
    @discardableResult
    func register<Service>(
        _ service: Service.Type,
        serviceType: DepinServiceType,
        factory: @escaping (Resolver) -> Service
    ) -> ServiceEntry<Service> {
        register(service, name: serviceType.name, factory: factory)
    }

    @discardableResult
    func register<Service>(
        _ service: Service.Type,
        serviceType: DepinServiceType,
        factory: @escaping () -> Service
    ) -> ServiceEntry<Service> {
        register(service, name: serviceType.name, factory: factory)
    }
}
```
3. Create an extension for `Injected` in your app
```swift
import Depin

extension Injected {
    convenience init(_ serviceName: DepinServiceType) {
        self.init(serviceName as ServiceName)
    }
}
```
4. Use a created registration method
```swift
container.register(EventEmitter<Void>.self, serviceType: .test) {
    EventEmitter<Void>()
}
.inObjectScope(.container)
```
5. Retrieve a dependency this way
```swift
@Injected(.test) private var eventEmitter: EventEmitter<Void>
```

## Unit testing
Use this approach to avoid stating your app when running unit tests
```swift
import Depin
import UIKit

@main
enum Main {

    @Space(\.dependenciesAssembler)
    private static var assembler: Assembler

    static func main() {

        assembler.apply(assemblies: [
            // ...
        ])

        var delegateClassName: String? {
            if NSClassFromString("XCTestCase") != nil { // Unit Testing
                nil
            } else { // App or UI testing
                NSStringFromClass(AppDelegate.self)
            }
        }

        UIApplicationMain(
            CommandLine.argc,
            CommandLine.unsafeArgv,
            nil,
            delegateClassName
        )
    }
}
```

Then, in your unit tests code, register mock dependencies for tested services
