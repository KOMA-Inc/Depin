import Swinject

@resultBuilder
public enum AssemblyResultBuilder {

    public static func buildBlock(_ components: Assembly...) -> [Assembly] {
        components
    }
}

public extension Assembler {

    /// Will apply the assemblies to the container. This is useful if you want to lazy load several assemblies into the
    /// assembler's container
    ///
    /// If this assembly type is load aware, the loaded hook will be invoked right after the container has assembled
    /// since after each call to ``apply(assemblies:)`` the container is fully loaded in its current state.
    ///
    /// - parameter assemblies: the assemblies to apply to the container
    ///
    func apply(@AssemblyResultBuilder assemblies: () -> [Assembly]) {
        self.apply(assemblies: assemblies())
    }
}
