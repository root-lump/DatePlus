import DatePlusCore
import SwiftUI
import WidgetKit

private let pinnedDaysURL = URL(string: "dateplus://deeplink?from=widget")

struct DatePlusWidget: Widget {
    let slot: ComplicationSlot

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: slot.widgetKind,
            provider: DateCounterProvider(slot: slot)
        ) { entry in
            DatePlusWidgetView(entry: entry)
                .widgetURL(pinnedDaysURL)
        }
        .configurationDisplayName(displayName)
        .supportedFamilies([
            .accessoryCorner,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }

    private var displayName: String {
        let localizer = AppLocalizer(locale: .current)
        let value = DateCounterProvider.loadDayInfo(for: slot)
        let description = localizer.daysDescription(
            days: value.days,
            includeFirstDay: value.includeFirstDay
        )
        return "\(slot.widgetKind) \(description)"
    }
}

@main
struct DatePlusWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        DatePlusWidget(slot: .one)
        if #available(watchOSApplicationExtension 10, *) {
            DatePlusWidget(slot: .two)
            DatePlusWidget(slot: .three)
        }
    }
}
