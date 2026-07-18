public struct CalculatorSettings: Equatable, Sendable {
    public var daysToAdd: Int
    public var includeFirstDay: Bool

    public init(daysToAdd: Int = 1, includeFirstDay: Bool = false) {
        self.daysToAdd = daysToAdd
        self.includeFirstDay = includeFirstDay
    }
}

public struct CalculatorSettingsStore: Sendable {
    private let store: any KeyValueStore

    public init(store: any KeyValueStore) {
        self.store = store
    }

    public func load() -> CalculatorSettings {
        CalculatorSettings(
            daysToAdd: store.integer(forKey: StorageConfiguration.daysToAddKey) ?? 1,
            includeFirstDay: store.boolean(
                forKey: StorageConfiguration.includeFirstDayKey
            ) ?? false
        )
    }

    public func saveDaysToAdd(_ value: Int) {
        store.write(value, forKey: StorageConfiguration.daysToAddKey)
    }

    public func saveIncludeFirstDay(_ value: Bool) {
        store.write(value, forKey: StorageConfiguration.includeFirstDayKey)
    }
}
