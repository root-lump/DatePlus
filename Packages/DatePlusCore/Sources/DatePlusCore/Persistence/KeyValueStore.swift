import Foundation

public protocol KeyValueStore: AnyObject, Sendable {
    func data(forKey key: String) -> Data?
    func write(_ data: Data, forKey key: String)
}

public final class UserDefaultsStore: KeyValueStore, @unchecked Sendable {
    private let defaults: UserDefaults

    public init(_ defaults: UserDefaults) {
        self.defaults = defaults
    }

    public func data(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    public func write(_ data: Data, forKey key: String) {
        defaults.set(data, forKey: key)
        defaults.synchronize()
    }
}
