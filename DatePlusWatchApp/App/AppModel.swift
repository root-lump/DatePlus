import DatePlusCore
import Foundation
import WidgetKit

@MainActor
final class AppModel: ObservableObject {
    @Published var daysToAdd: Int {
        didSet {
            settingsStore.saveDaysToAdd(daysToAdd)
            updateFutureDate()
        }
    }
    @Published var includeFirstDay: Bool {
        didSet {
            settingsStore.saveIncludeFirstDay(includeFirstDay)
            updateFutureDate()
        }
    }
    @Published private(set) var futureDate: Date
    @Published private(set) var pinnedDays: [DayInfo]

    private let settingsStore: CalculatorSettingsStore
    private let pinnedStore: PinnedDayStore
    private let complicationStore: ComplicationStore
    private let reloadTimelines: (String) -> Void

    convenience init(defaults: UserDefaults = .standard) {
        let appGroupDefaults = UserDefaults(
            suiteName: StorageConfiguration.appGroupIdentifier
        ) ?? .standard

        self.init(
            standardStore: UserDefaultsStore(defaults),
            complicationStore: ComplicationStore(
                store: UserDefaultsStore(appGroupDefaults)
            ),
            reloadTimelines: { WidgetCenter.shared.reloadTimelines(ofKind: $0) },
            reloadAllTimelines: { WidgetCenter.shared.reloadAllTimelines() }
        )
    }

    init(
        standardStore: any KeyValueStore,
        complicationStore: ComplicationStore,
        reloadTimelines: @escaping (String) -> Void,
        reloadAllTimelines: @escaping () -> Void
    ) {
        let settingsStore = CalculatorSettingsStore(store: standardStore)
        let settings = settingsStore.load()

        self.settingsStore = settingsStore
        daysToAdd = settings.daysToAdd
        includeFirstDay = settings.includeFirstDay
        futureDate = DateCalculator.calculate(
            daysToAdd: settings.daysToAdd,
            includeFirstDay: settings.includeFirstDay
        )
        pinnedStore = PinnedDayStore(store: standardStore)
        self.complicationStore = complicationStore
        self.reloadTimelines = reloadTimelines
        pinnedDays = pinnedStore.load()
        // Watch faces and the Smart Stack keep archived timelines across app
        // updates. Rebuild them once per launch so stale content cannot outlive
        // a binary or data change.
        reloadAllTimelines()
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

    @discardableResult
    func pin(days: Int, includeFirstDay: Bool) -> Bool {
        guard !isPinned(days: days, includeFirstDay: includeFirstDay) else {
            return false
        }

        pinnedDays = pinnedStore.add(DayInfo(days: days, includeFirstDay: includeFirstDay))
        return true
    }

    func removePinned(_ dayInfo: DayInfo) {
        pinnedDays = pinnedStore.remove(dayInfo)
    }

    func register(_ dayInfo: DayInfo, in slot: ComplicationSlot) {
        complicationStore.register(dayInfo, in: slot)
        reloadTimelines(slot.widgetKind)
    }

    func complication(for slot: ComplicationSlot) -> DayInfo {
        complicationStore.dayInfo(for: slot)
    }

    func toggleIncludeFirstDay() {
        includeFirstDay.toggle()
    }

    func refreshFutureDate() {
        updateFutureDate()
    }

    private func updateFutureDate() {
        futureDate = DateCalculator.calculate(
            daysToAdd: daysToAdd,
            includeFirstDay: includeFirstDay
        )
    }
}
