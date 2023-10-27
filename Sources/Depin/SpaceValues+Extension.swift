import Swinject

public enum DependenciesContainerKey: SpaceKey {
    public static let defaultValue = Container()
}

public enum DependenciesAssemblerKey: SpaceKey {
    @Space(\.dependenciesContainer)
    static private var container: Swinject.Container

    public static let defaultValue = Assembler(container: container)
}

public extension SpaceValues {
    var dependenciesContainer: Container {
        self[DependenciesContainerKey.self]
    }

    var dependenciesAssembler: Assembler {
        self[DependenciesAssemblerKey.self]
    }
}
