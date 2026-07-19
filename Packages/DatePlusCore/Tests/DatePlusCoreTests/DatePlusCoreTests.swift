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

    @Test("Pinned days decode the JSON shape written by released builds")
    func legacyPinnedDayFixture() throws {
        let memory = MemoryKeyValueStore()
        memory.write(try legacyFixtureData(), forKey: StorageConfiguration.pinnedDaysKey)

        let values = PinnedDayStore(store: memory).load()

        #expect(values.count == 3)
        #expect(values.map(\.id.uuidString) == [
            "00000000-0000-0000-0000-000000000101",
            "00000000-0000-0000-0000-000000000102",
            "00000000-0000-0000-0000-000000000103",
        ])
        #expect(values.map(\.days) == [7, 30, 100])
        #expect(values.map(\.includeFirstDay) == [false, true, false])
    }

    @Test("Pinned days fall back without rewriting malformed persisted data")
    func malformedPinnedDayPersistence() {
        let memory = MemoryKeyValueStore()
        let malformed = Data("not-json".utf8)
        memory.write(malformed, forKey: StorageConfiguration.pinnedDaysKey)

        #expect(PinnedDayStore(store: memory).load().isEmpty)
        #expect(memory.data(forKey: StorageConfiguration.pinnedDaysKey) == malformed)

        let missingRequiredField = Data(
            #"[{"days":7,"includeFirstDay":false}]"#.utf8
        )
        memory.write(missingRequiredField, forKey: StorageConfiguration.pinnedDaysKey)
        #expect(PinnedDayStore(store: memory).load().isEmpty)
    }

    @Test("Calculator settings preserve the existing defaults keys")
    func calculatorSettingsPersistence() {
        let memory = MemoryKeyValueStore()
        let store = CalculatorSettingsStore(store: memory)

        #expect(store.load() == CalculatorSettings())
        store.saveDaysToAdd(42)
        store.saveIncludeFirstDay(true)

        #expect(store.load() == CalculatorSettings(daysToAdd: 42, includeFirstDay: true))
        #expect(memory.integer(forKey: StorageConfiguration.daysToAddKey) == 42)
        #expect(memory.boolean(forKey: StorageConfiguration.includeFirstDayKey) == true)
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

    @Test("Complication slots decode the positional array from released builds")
    func legacyComplicationFixture() throws {
        let memory = MemoryKeyValueStore()
        memory.write(
            try legacyFixtureData(),
            forKey: StorageConfiguration.complicationDaysKey
        )
        let store = ComplicationStore(store: memory)

        #expect(store.dayInfo(for: .one).id.uuidString == "00000000-0000-0000-0000-000000000101")
        #expect(store.dayInfo(for: .two).id.uuidString == "00000000-0000-0000-0000-000000000102")
        #expect(store.dayInfo(for: .three).id.uuidString == "00000000-0000-0000-0000-000000000103")
    }

    @Test("Complication storage normalizes missing, malformed, short, and long arrays")
    func complicationNormalization() throws {
        let memory = MemoryKeyValueStore()
        let store = ComplicationStore(store: memory)
        let fallback = DayInfo(days: 1, includeFirstDay: true)

        #expect(store.load() == [fallback, fallback, fallback])

        let malformed = Data("not-json".utf8)
        memory.write(malformed, forKey: StorageConfiguration.complicationDaysKey)
        #expect(store.load() == [fallback, fallback, fallback])
        #expect(memory.data(forKey: StorageConfiguration.complicationDaysKey) == malformed)

        let missingRequiredField = Data(
            #"[{"days":7,"includeFirstDay":false}]"#.utf8
        )
        memory.write(
            missingRequiredField,
            forKey: StorageConfiguration.complicationDaysKey
        )
        #expect(store.load() == [fallback, fallback, fallback])
        #expect(
            memory.data(forKey: StorageConfiguration.complicationDaysKey)
                == missingRequiredField
        )

        let first = DayInfo(days: 10, includeFirstDay: false)
        memory.write(
            try JSONEncoder().encode([first]),
            forKey: StorageConfiguration.complicationDaysKey
        )
        #expect(store.load() == [first, fallback, fallback])

        let values = [
            DayInfo(days: 10, includeFirstDay: false),
            DayInfo(days: 20, includeFirstDay: true),
            DayInfo(days: 30, includeFirstDay: false),
            DayInfo(days: 40, includeFirstDay: true),
        ]
        memory.write(
            try JSONEncoder().encode(values),
            forKey: StorageConfiguration.complicationDaysKey
        )
        #expect(store.load() == Array(values.prefix(3)))
    }

    @Test("String Catalog localization follows an explicitly injected locale")
    func localization() throws {
        if let catalogURL = Bundle.module.url(
            forResource: "Localizable",
            withExtension: "xcstrings"
        ) {
            let data = try Data(contentsOf: catalogURL)
            let catalog = try #require(
                JSONSerialization.jsonObject(with: data) as? [String: Any]
            )
            let strings = try #require(catalog["strings"] as? [String: Any])
            let delete = try #require(strings["delete"] as? [String: Any])
            let localizations = try #require(
                delete["localizations"] as? [String: Any]
            )

            #expect(catalogValue(in: localizations, language: "en") == "Delete")
            #expect(catalogValue(in: localizations, language: "ja") == "削除")

            let multiline = try #require(
                strings["day_later_multiline"] as? [String: Any]
            )
            let multilineLocalizations = try #require(
                multiline["localizations"] as? [String: Any]
            )
            #expect(
                catalogValue(in: multilineLocalizations, language: "en") == "day\nlater"
            )
            #expect(catalogValue(in: multilineLocalizations, language: "ja") == "日後")

            let widgetDescription = try #require(
                strings["widget_description"] as? [String: Any]
            )
            let widgetDescriptionLocalizations = try #require(
                widgetDescription["localizations"] as? [String: Any]
            )
            #expect(
                catalogValue(in: widgetDescriptionLocalizations, language: "en")
                    == "Shows the date calculated for this complication slot."
            )
            #expect(
                catalogValue(in: widgetDescriptionLocalizations, language: "ja")
                    == "このコンプリケーション枠に設定した計算日を表示します。"
            )
            return
        }

        let english = AppLocalizer(locale: Locale(identifier: "en"))
        let japanese = AppLocalizer(locale: Locale(identifier: "ja"))

        #expect(english.text(.delete) == "Delete")
        #expect(japanese.text(.delete) == "削除")
        #expect(english.text(.dayLaterMultiline) == "day\nlater")
        #expect(japanese.text(.dayLaterMultiline) == "日後")
        #expect(english.daysDescription(days: 21, includeFirstDay: true) == "21st day")
        #expect(english.daysDescription(days: 1, includeFirstDay: false) == "1 day later")
        #expect(english.daysDescription(days: 21, includeFirstDay: false) == "21 days later")
        #expect(japanese.daysDescription(days: 21, includeFirstDay: false) == "21日後")
        #expect(
            english.text(.widgetDescription)
                == "Shows the date calculated for this complication slot."
        )
        #expect(
            japanese.text(.widgetDescription)
                == "このコンプリケーション枠に設定した計算日を表示します。"
        )
    }
}

private func legacyFixtureData() throws -> Data {
    let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    return try Data(
        contentsOf: testsDirectory
            .appendingPathComponent("Fixtures", isDirectory: true)
            .appendingPathComponent("LegacyDayInfos.json")
    )
}

private func catalogValue(
    in localizations: [String: Any],
    language: String
) -> String? {
    let localization = localizations[language] as? [String: Any]
    let stringUnit = localization?["stringUnit"] as? [String: Any]
    return stringUnit?["value"] as? String
}

private final class MemoryKeyValueStore: KeyValueStore, @unchecked Sendable {
    private let lock = NSLock()
    private var dataValues: [String: Data] = [:]
    private var integerValues: [String: Int] = [:]
    private var booleanValues: [String: Bool] = [:]

    func data(forKey key: String) -> Data? {
        lock.withLock { dataValues[key] }
    }

    func integer(forKey key: String) -> Int? {
        lock.withLock { integerValues[key] }
    }

    func boolean(forKey key: String) -> Bool? {
        lock.withLock { booleanValues[key] }
    }

    func write(_ data: Data, forKey key: String) {
        lock.withLock { dataValues[key] = data }
    }

    func write(_ value: Int, forKey key: String) {
        lock.withLock { integerValues[key] = value }
    }

    func write(_ value: Bool, forKey key: String) {
        lock.withLock { booleanValues[key] = value }
    }
}
