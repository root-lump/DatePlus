import WidgetKit
import SwiftUI

struct DateCounterEntry: TimelineEntry {
    let date: Date
    let daysToAdd: Int
    let includeFirstDay: Bool
}

func getRegisterdValue(widgetKind: String) -> DayInfo {
    let dayInfos = loadComplicationDayInfo()
    var dayInfo: DayInfo? = nil
    
    switch widgetKind {
    case "[1]":
        dayInfo = dayInfos.indices.contains(0) ? dayInfos[0] : nil
    case "[2]":
        dayInfo = dayInfos.indices.contains(1) ? dayInfos[1] : nil
    case "[3]":
        dayInfo = dayInfos.indices.contains(2) ? dayInfos[2] : nil
    default:
        break
    }
    
    return dayInfo ?? DayInfo(days: 1, includeFirstDay: true)
}

struct DateCounterProvider: TimelineProvider {
    var widgetKind: String
    
    func placeholder(in context: Context) -> DateCounterEntry {
        let dayInfo = getRegisterdValue(widgetKind: widgetKind)
        return DateCounterEntry(date: Date(), daysToAdd: dayInfo.days, includeFirstDay: dayInfo.includeFirstDay)    }
    
    // data for preview
    func getSnapshot(in context: Context, completion: @escaping (DateCounterEntry) -> Void) {
        let dayInfo = getRegisterdValue(widgetKind: widgetKind)
        let entry = DateCounterEntry(date: Date(), daysToAdd: dayInfo.days, includeFirstDay: dayInfo.includeFirstDay)
        completion(entry)
    }
    
    // adjustment of update timing and data acquisition
    func getTimeline(in context: Context, completion: @escaping (Timeline<DateCounterEntry>) -> Void) {
        let dayInfo = getRegisterdValue(widgetKind: widgetKind)
        // Create a timeline entry for "now."
        let now = Date()
        let entry = DateCounterEntry(
            date: now,
            daysToAdd: dayInfo.days,
            includeFirstDay: dayInfo.includeFirstDay
        )
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.day? += 1
        let nextMidnight = calendar.date(from: components)
        
        // Create the timeline with the entry and a reload policy with the date
        // for the next update.
        let timeline = Timeline(
            entries:[entry],
            policy: .after(nextMidnight ?? now)
        )
        
        // Call the completion to pass the timeline to WidgetKit.
        completion(timeline)
    }
}

struct DatePlusComplicationView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    // Get the widget's family.
    @Environment(\.widgetFamily) private var family
    
    var entry: DateCounterProvider.Entry
    
    var body: some View {
        let futureDate = calculateDate(daysToAdd: entry.daysToAdd, includeFirstDay: entry.includeFirstDay)
        let daysToAdd = entry.daysToAdd
        let includeFirstDay = entry.includeFirstDay
        
        switch family {
        case .accessoryCircular:
            AccessoryCircularView(localizationManager: localizationManager, futureDate: futureDate, daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
        case .accessoryCorner:
            AccessoryCornerView(localizationManager: localizationManager, futureDate: futureDate, daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
        case .accessoryRectangular:
            AccessoryRectangularView(localizationManager: localizationManager, futureDate: futureDate, daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
        case .accessoryInline:
            AccessoryInlineView(localizationManager: localizationManager, futureDate: futureDate, daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
        default:
            Image("AppIcon")
        }
    }
}

func getDisplayName(kind: String) -> String {
    let localizationManager = LocalizationManager(String(localized: "Locale Code"))
    let dayInfo = getRegisterdValue(widgetKind: kind)
    return kind + " " + getDaysToAddStrings(daysToAdd: dayInfo.days, includeFirstDay: dayInfo.includeFirstDay, localizationManager: localizationManager)
    
}

struct WidgetOne: Widget {
    let kind: String = "[1]"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateCounterProvider(widgetKind: kind)) { entry in
            DatePlusComplicationView(entry: entry)
                .widgetURL(URL(string: "dateplus://deeplink?from=widget"))
        }
        .configurationDisplayName(getDisplayName(kind: kind))
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct WidgetTwo: Widget {
    let kind: String = "[2]"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateCounterProvider(widgetKind: kind)) { entry in
            DatePlusComplicationView(entry: entry)
                .widgetURL(URL(string: "dateplus://deeplink?from=widget"))
        }
        .configurationDisplayName(getDisplayName(kind: kind))
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct WidgetThree: Widget {
    let kind: String = "[3]"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateCounterProvider(widgetKind: kind)) { entry in
            DatePlusComplicationView(entry: entry)
                .widgetURL(URL(string: "dateplus://deeplink?from=widget"))
        }
        .configurationDisplayName(getDisplayName(kind: kind))
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

@main
struct DatePlusWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        widgets()
    }
    
    func widgets() -> some Widget {
        if #available(watchOS 10, *) {
            return WidgetBundleBuilder.buildBlock(WidgetOne(), WidgetTwo(), WidgetThree())
        } else {
            return WidgetOne()
        }
    }
}

struct DatePlusComplicationPreviews: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            DatePlusComplicationView(localizationManager: LocalizationManager(id), entry: DateCounterEntry(date: Date(), daysToAdd: 1, includeFirstDay: false))
                .previewContext(WidgetPreviewContext(family: .accessoryCorner))
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}

