import Foundation

public struct ComplicationStore: Sendable {
    public static let slotCount = 3

    private let store: any KeyValueStore
    private let key: String

    public init(
        store: any KeyValueStore,
        key: String = StorageConfiguration.complicationDaysKey
    ) {
        self.store = store
        self.key = key
    }

    public func load() -> [DayInfo] {
        let decoded: [DayInfo]
        if let data = store.data(forKey: key),
           let values = try? JSONDecoder().decode([DayInfo].self, from: data) {
            decoded = values
        } else {
            decoded = []
        }
        return normalized(decoded)
    }

    public func dayInfo(for slot: ComplicationSlot) -> DayInfo {
        load()[slot.index]
    }

    @discardableResult
    public func register(_ dayInfo: DayInfo, in slot: ComplicationSlot) -> [DayInfo] {
        var values = load()
        values[slot.index] = dayInfo
        save(values)
        return values
    }

    public func save(_ values: [DayInfo]) {
        guard let data = try? JSONEncoder().encode(normalized(values)) else {
            return
        }
        store.write(data, forKey: key)
    }

    private func normalized(_ values: [DayInfo]) -> [DayInfo] {
        // Released versions store complications as a positional three-item
        // array. Padding or trimming preserves the legacy slot indices.
        var result = Array(values.prefix(Self.slotCount))
        while result.count < Self.slotCount {
            result.append(DayInfo(days: 1, includeFirstDay: true))
        }
        return result
    }
}
