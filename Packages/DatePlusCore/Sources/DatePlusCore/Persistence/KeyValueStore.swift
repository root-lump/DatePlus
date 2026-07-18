import Foundation

public protocol KeyValueStore: AnyObject, Sendable {
    func data(forKey key: String) -> Data?
    func write(_ data: Data, forKey key: String)
}

extension UserDefaults: KeyValueStore {
    public func write(_ data: Data, forKey key: String) {
        set(data, forKey: key)
    }
}
