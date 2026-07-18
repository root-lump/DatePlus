import DatePlusCore
import SwiftUI
import WidgetKit

struct DatePlusWidgetView: View {
    @Environment(\.locale) private var locale
    @Environment(\.widgetFamily) private var family

    let entry: DateCounterEntry

    private var futureDate: Date {
        DateCalculator.calculate(
            from: entry.date,
            daysToAdd: entry.dayInfo.days,
            includeFirstDay: entry.dayInfo.includeFirstDay
        )
    }

    private var appLocale: Locale {
        Bundle.main.preferredLocalizations.first.map { Locale(identifier: $0) } ?? locale
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
        DatePlusWidgetView(
            entry: DateCounterEntry(
                date: Date(),
                dayInfo: DayInfo(days: 3, includeFirstDay: false)
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryCorner))
    }
}
