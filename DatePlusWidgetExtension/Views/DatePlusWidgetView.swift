import DatePlusCore
import SwiftUI
import WidgetKit

struct DatePlusWidgetView: View {
    @Environment(\.locale) private var locale
    @Environment(\.widgetFamily) private var family

    let entry: DateCounterEntry
    private let localeOverride: Locale?

    init(entry: DateCounterEntry, localeOverride: Locale? = nil) {
        self.entry = entry
        self.localeOverride = localeOverride
    }

    private var futureDate: Date {
        DateCalculator.calculate(
            from: entry.date,
            daysToAdd: entry.dayInfo.days,
            includeFirstDay: entry.dayInfo.includeFirstDay
        )
    }

    private var appLocale: Locale {
        if let localeOverride {
            return localeOverride
        }
        // WidgetKit's environment locale can differ from the app localization.
        // Prefer the extension bundle to keep every label in one language.
        return Bundle.main.preferredLocalizations.first.map { Locale(identifier: $0) } ?? locale
    }

    var body: some View {
        let content = WidgetContent(
            date: futureDate,
            dayInfo: entry.dayInfo,
            locale: appLocale
        )

        switch family {
        case .accessoryCircular:
            AccessoryCircularView()
        case .accessoryCorner:
            AccessoryCornerView(content: content)
        case .accessoryRectangular:
            AccessoryRectangularView(content: content)
        case .accessoryInline:
            AccessoryInlineView(content: content)
        default:
            Image(systemName: "calendar.badge.clock")
        }
    }
}

struct WidgetContent {
    let date: Date
    let dayInfo: DayInfo
    let locale: Locale

    var dateText: String { DateTextFormatter(locale: locale).compactDate(date) }
    var fullDateText: String { DateTextFormatter(locale: locale).fullDate(date) }
    var daysText: String {
        AppLocalizer(locale: locale).daysDescription(
            days: dayInfo.days,
            includeFirstDay: dayInfo.includeFirstDay
        )
    }
    var cornerDaysText: String {
        AppLocalizer(locale: locale).cornerDaysDescription(
            days: dayInfo.days,
            includeFirstDay: dayInfo.includeFirstDay
        )
    }
}

struct DatePlusWidgetPreview: PreviewProvider {
    static var previews: some View {
        Group {
            previews(localeIdentifier: "en", displayLanguage: "English")
            previews(localeIdentifier: "ja", displayLanguage: "Japanese")
        }
    }

    private static func previews(
        localeIdentifier: String,
        displayLanguage: String
    ) -> some View {
        Group {
            preview(
                family: .accessoryCorner,
                familyName: "Corner",
                localeIdentifier: localeIdentifier,
                displayLanguage: displayLanguage
            )
            preview(
                family: .accessoryCircular,
                familyName: "Circular",
                localeIdentifier: localeIdentifier,
                displayLanguage: displayLanguage
            )
            preview(
                family: .accessoryRectangular,
                familyName: "Rectangular",
                localeIdentifier: localeIdentifier,
                displayLanguage: displayLanguage
            )
            preview(
                family: .accessoryInline,
                familyName: "Inline",
                localeIdentifier: localeIdentifier,
                displayLanguage: displayLanguage
            )
        }
    }

    private static func preview(
        family: WidgetFamily,
        familyName: String,
        localeIdentifier: String,
        displayLanguage: String
    ) -> some View {
        DatePlusWidgetView(
            entry: DateCounterEntry(
                date: Date(),
                dayInfo: DayInfo(days: 3, includeFirstDay: false)
            ),
            localeOverride: Locale(identifier: localeIdentifier)
        )
        .previewContext(WidgetPreviewContext(family: family))
        .previewDisplayName("\(displayLanguage) – \(familyName)")
    }
}
