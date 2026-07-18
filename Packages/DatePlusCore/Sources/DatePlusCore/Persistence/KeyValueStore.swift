import Foundation

public protocol KeyValueStore: AnyObject, Sendable {
    func data(forKey key: String) -> Data?
    func integer(forKey key: String) -> Int?
    func boolean(forKey key: String) -> Bool?
    func write(_ data: Data, forKey key: String)
    func write(_ value: Int, forKey key: String)
    func write(_ value: Bool, forKey key: String)
}

public final class UserDefaultsStore: KeyValueStore, @unchecked Sendable {
    private let defaults: UserDefaults

    public init(_ defaults: UserDefaults) {
        self.defaults = defaults
    }

    public func data(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    public func integer(forKey key: String) -> Int? {
        guard defaults.object(forKey: key) != nil else { return nil }
        return defaults.integer(forKey: key)
    }

    public func boolean(forKey key: String) -> Bool? {
        guard defaults.object(forKey: key) != nil else { return nil }
        return defaults.bool(forKey: key)
    }

    public func write(_ data: Data, forKey key: String) {
        defaults.set(data, forKey: key)
        defaults.synchronize()
    }

    public func write(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    public func write(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
}
