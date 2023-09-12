import WidgetKit
import SwiftUI

struct DateCounterEntry: TimelineEntry {
    let date: Date
    let daysToAdd: Int
    let includeFirstDay: Bool
}

struct DateCounterProvider: TimelineProvider {
    func placeholder(in context: Context) -> DateCounterEntry {
        DateCounterEntry(date: Date(), daysToAdd: 0, includeFirstDay: false)
    }
    
    func getRegisterdValue() -> (Int, Bool) {
        let userDefaults: UserDefaults? = UserDefaults(suiteName: "group.net.root-lump.date-plus")
        
        let daysToAdd = userDefaults?.integer(forKey: "daysToAdd") ?? 0
        let includeFirstDay = userDefaults?.bool(forKey: "includeFirstDay") ?? false
        
        return (daysToAdd, includeFirstDay)
    }
    
    // data for preview
    func getSnapshot(in context: Context, completion: @escaping (DateCounterEntry) -> Void) {
        let (daysToAdd, includeFirstDay) = getRegisterdValue()
        let entry = DateCounterEntry(date: Date(), daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
        completion(entry)
    }
    
    // adjustment of update timing and data acquisition
    func getTimeline(in context: Context, completion: @escaping (Timeline<DateCounterEntry>) -> Void) {
        let (daysToAdd, includeFirstDay) = getRegisterdValue()
        // Create a timeline entry for "now."
        let now = Date()
        let entry = DateCounterEntry(
            date: now,
            daysToAdd: daysToAdd,
            includeFirstDay: includeFirstDay
        )
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.day! += 1
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
            //        case .accessoryCircular:
        case .accessoryCorner:
            AccessoryCornerView(localizationManager: localizationManager, futureDate: futureDate, daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
        case .accessoryRectangular:
            AccessoryRectangularView(localizationManager: localizationManager, futureDate: futureDate, daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
            //        case .accessoryInline:
        default:
            Image("AppIcon")
        }
    }
}

@main
struct DatePlusComplication: Widget {
    let kind: String = "date_plus.accesory_corner"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateCounterProvider()) { entry in
            DatePlusComplicationView(entry: entry)
                .widgetURL(URL(string: "dateplus://deeplink?from=widget"))
            
        }
        .configurationDisplayName("DatePlus Widget")
        .supportedFamilies([.accessoryCorner, .accessoryRectangular])
    }
}

struct DatePlusWidgets: WidgetBundle {
    var body: some Widget {
        DatePlusComplication()
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

