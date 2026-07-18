import DatePlusCore
import Foundation
import WidgetKit

struct DateCounterProvider: TimelineProvider {
    let slot: ComplicationSlot

    func placeholder(in context: Context) -> DateCounterEntry {
        DateCounterEntry(date: Date(), dayInfo: Self.loadDayInfo(for: slot))
    }

    func getSnapshot(in context: Context, completion: @escaping (DateCounterEntry) -> Void) {
        completion(DateCounterEntry(date: Date(), dayInfo: Self.loadDayInfo(for: slot)))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<DateCounterEntry>) -> Void
    ) {
        let now = Date()
        let entry = DateCounterEntry(date: now, dayInfo: Self.loadDayInfo(for: slot))
        let nextMidnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }

    static func loadDayInfo(for slot: ComplicationSlot) -> DayInfo {
        let defaults = UserDefaults(
            suiteName: StorageConfiguration.appGroupIdentifier
        ) ?? .standard
        return ComplicationStore(
            store: UserDefaultsStore(defaults)
        ).dayInfo(for: slot)
    }
}
