import DatePlusCore
import SwiftUI
import WidgetKit

private let pinnedDaysURL = URL(string: "dateplus://deeplink?from=widget")

struct WidgetOne: Widget {
    var body: some WidgetConfiguration {
        configuration(for: .one)
    }
}

struct WidgetTwo: Widget {
    var body: some WidgetConfiguration {
        configuration(for: .two)
    }
}

struct WidgetThree: Widget {
    var body: some WidgetConfiguration {
        configuration(for: .three)
    }
}

@main
struct DatePlusWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        WidgetOne()
        if #available(watchOSApplicationExtension 10, *) {
            WidgetTwo()
            WidgetThree()
        }
    }
}

private func configuration(for slot: ComplicationSlot) -> some WidgetConfiguration {
    let localizer = AppLocalizer(locale: .current)
    let value = DateCounterProvider.loadDayInfo(for: slot)
    let description = localizer.daysDescription(
        days: value.days,
        includeFirstDay: value.includeFirstDay
    )

    return StaticConfiguration(
        kind: slot.widgetKind,
        provider: DateCounterProvider(slot: slot)
    ) { entry in
        DatePlusWidgetView(entry: entry)
            .widgetURL(pinnedDaysURL)
    }
    .configurationDisplayName("\(slot.widgetKind) \(description)")
    .supportedFamilies([
        .accessoryCorner,
        .accessoryCircular,
        .accessoryRectangular,
        .accessoryInline,
    ])
}
