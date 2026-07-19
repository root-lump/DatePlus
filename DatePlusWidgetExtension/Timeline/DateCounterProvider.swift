import DatePlusCore
import Foundation
import WidgetKit

struct DateCounterProvider: TimelineProvider {
    let slot: ComplicationSlot

    func placeholder(in context: Context) -> DateCounterEntry {
        // Gallery discovery must not depend on App Group availability. WidgetKit
        // can always archive this deterministic entry.
        DateCounterEntry(date: Date(), dayInfo: DayInfo(days: 1, includeFirstDay: true))
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
        // Date-based output changes at local midnight. Retry in an hour only when
        // the calendar cannot resolve the next boundary.
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
