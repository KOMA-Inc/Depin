public protocol SpaceKey {

    /// The associated type representing the type of the environment key's
    /// value.
    associatedtype Value

    /// The default value for the environment key.
    static var defaultValue: Self.Value { get }
}

public struct SpaceValues : CustomStringConvertible {

    private var storage: [ObjectIdentifier: Any] = [:]

    public var description: String {
        String(describing: self)
    }

    public subscript<K>(key: K.Type) -> K.Value where K : SpaceKey {
        get { storage[ObjectIdentifier(key)] as? K.Value ?? K.defaultValue }
        set { storage[ObjectIdentifier(key)] = newValue }
    }
}

@propertyWrapper
public struct Space<Value> {

    private let keyPath: KeyPath<SpaceValues, Value>

    public init(_ keyPath: KeyPath<SpaceValues, Value>) {
        self.keyPath = keyPath
    }

    public var wrappedValue: Value {
        SpaceValues()[keyPath: keyPath]
    }
}
