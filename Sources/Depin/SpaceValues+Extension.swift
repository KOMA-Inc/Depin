import Swinject

public enum DependenciesContainerKey: SpaceKey {
    public static let defaultValue = Container()
}

public extension SpaceValues {
    var dependenciesContainer: Container {
        self[DependenciesContainerKey.self]
    }
}
