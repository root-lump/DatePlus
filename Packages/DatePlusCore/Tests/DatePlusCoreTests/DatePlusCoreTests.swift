import Foundation
import Testing
@testable import DatePlusCore

@Suite("DatePlusCore")
struct DatePlusCoreTests {
    @Test("DayInfo keeps its persisted shape while equality ignores the generated id")
    func dayInfoCodableAndEquality() throws {
        let first = DayInfo(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            days: 10,
            includeFirstDay: true
        )
        let second = DayInfo(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            days: 10,
            includeFirstDay: true
        )

        #expect(first == second)
        let data = try JSONEncoder().encode(first)
        let decoded = try JSONDecoder().decode(DayInfo.self, from: data)
        #expect(decoded.id == first.id)
        #expect(decoded.days == 10)
        #expect(decoded.includeFirstDay)
    }

    @Test("Date calculation supports inclusive and exclusive counting")
    func dateCalculation() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let start = try #require(calendar.date(from: DateComponents(year: 2026, month: 7, day: 18)))

        let exclusive = DateCalculator.calculate(
            from: start,
            daysToAdd: 3,
            includeFirstDay: false,
            calendar: calendar
        )
        let inclusive = DateCalculator.calculate(
            from: start,
            daysToAdd: 3,
            includeFirstDay: true,
            calendar: calendar
        )

        #expect(calendar.component(.day, from: exclusive) == 21)
        #expect(calendar.component(.day, from: inclusive) == 20)
    }

    @Test("English ordinals handle teen suffixes")
    func englishOrdinals() {
        let formatter = DateTextFormatter(locale: Locale(identifier: "en_US"))
        #expect(formatter.ordinal(1) == "1st")
        #expect(formatter.ordinal(2) == "2nd")
        #expect(formatter.ordinal(3) == "3rd")
        #expect(formatter.ordinal(11) == "11th")
        #expect(formatter.ordinal(12) == "12th")
        #expect(formatter.ordinal(13) == "13th")
        #expect(formatter.ordinal(21) == "21st")
    }

    @Test("Pinned days remain compatible with the existing defaults key")
    func pinnedDayPersistence() {
        let memory = MemoryKeyValueStore()
        let store = PinnedDayStore(store: memory)
        let value = DayInfo(days: 7, includeFirstDay: false)

        #expect(store.add(value) == [value])
        #expect(store.add(value) == [value])
        #expect(memory.data(forKey: StorageConfiguration.pinnedDaysKey) != nil)
        #expect(store.remove(value).isEmpty)
    }

    @Test("Complication storage always exposes three stable widget slots")
    func complicationPersistence() {
        let memory = MemoryKeyValueStore()
        let store = ComplicationStore(store: memory)
        let value = DayInfo(days: 30, includeFirstDay: false)

        #expect(store.load().count == 3)
        #expect(ComplicationSlot.two.widgetKind == "[2]")
        #expect(ComplicationSlot(widgetKind: "[3]") == .three)
        store.register(value, in: .two)
        #expect(store.dayInfo(for: .two) == value)
        #expect(memory.data(forKey: StorageConfiguration.complicationDaysKey) != nil)
    }

    @Test("String Catalog localization follows an explicitly injected locale")
    func localization() {
        let english = AppLocalizer(locale: Locale(identifier: "en"))
        let japanese = AppLocalizer(locale: Locale(identifier: "ja"))

        #expect(english.text(.delete) == "Delete")
        #expect(japanese.text(.delete) == "削除")
        #expect(english.daysDescription(days: 21, includeFirstDay: true) == "21st day")
        #expect(japanese.daysDescription(days: 21, includeFirstDay: false) == "21日後")
    }
}

private final class MemoryKeyValueStore: KeyValueStore, @unchecked Sendable {
    private let lock = NSLock()
    private var values: [String: Data] = [:]

    func data(forKey key: String) -> Data? {
        lock.withLock { values[key] }
    }

    func write(_ data: Data, forKey key: String) {
        lock.withLock { values[key] = data }
    }
}
