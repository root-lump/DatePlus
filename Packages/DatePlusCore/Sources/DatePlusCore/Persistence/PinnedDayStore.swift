import Foundation

public struct PinnedDayStore: Sendable {
    private let store: any KeyValueStore
    private let key: String

    public init(
        store: any KeyValueStore,
        key: String = StorageConfiguration.pinnedDaysKey
    ) {
        self.store = store
        self.key = key
    }

    public func load() -> [DayInfo] {
        guard let data = store.data(forKey: key) else {
            return []
        }
        return (try? JSONDecoder().decode([DayInfo].self, from: data)) ?? []
    }

    @discardableResult
    public func add(_ dayInfo: DayInfo) -> [DayInfo] {
        var days = load()
        guard !days.contains(dayInfo) else {
            return days
        }
        days.append(dayInfo)
        save(days)
        return days
    }

    @discardableResult
    public func remove(_ dayInfo: DayInfo) -> [DayInfo] {
        var days = load()
        days.removeAll { $0 == dayInfo }
        save(days)
        return days
    }

    public func contains(_ dayInfo: DayInfo) -> Bool {
        load().contains(dayInfo)
    }

    public func save(_ days: [DayInfo]) {
        guard let data = try? JSONEncoder().encode(days) else {
            return
        }
        store.write(data, forKey: key)
    }
}
