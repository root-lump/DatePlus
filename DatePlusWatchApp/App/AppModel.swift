import DatePlusCore
import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var pinnedDays: [DayInfo]

    private let pinnedStore: PinnedDayStore
    private let complicationStore: ComplicationStore

    init(
        defaults: UserDefaults = .standard,
        appGroupDefaults: UserDefaults = UserDefaults(
            suiteName: StorageConfiguration.appGroupIdentifier
        ) ?? .standard
    ) {
        pinnedStore = PinnedDayStore(store: UserDefaultsStore(defaults))
        complicationStore = ComplicationStore(
            store: UserDefaultsStore(appGroupDefaults)
        )
        pinnedDays = pinnedStore.load()
    }

    func isPinned(days: Int, includeFirstDay: Bool) -> Bool {
        pinnedStore.contains(DayInfo(days: days, includeFirstDay: includeFirstDay))
    }

    func togglePinned(days: Int, includeFirstDay: Bool) {
        let value = DayInfo(days: days, includeFirstDay: includeFirstDay)
        pinnedDays = isPinned(days: days, includeFirstDay: includeFirstDay)
            ? pinnedStore.remove(value)
            : pinnedStore.add(value)
    }

    func removePinned(_ dayInfo: DayInfo) {
        pinnedDays = pinnedStore.remove(dayInfo)
    }

    func register(_ dayInfo: DayInfo, in slot: ComplicationSlot) {
        complicationStore.register(dayInfo, in: slot)
    }

    func complication(for slot: ComplicationSlot) -> DayInfo {
        complicationStore.dayInfo(for: slot)
    }
}
