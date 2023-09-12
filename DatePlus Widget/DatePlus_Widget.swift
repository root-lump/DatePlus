
import WidgetKit
import SwiftUI

func getDaysToAddStrings(daysToAdd: Int, includeFirstDay: Bool, localizationManager: LocalizationManager) -> String {
    if #available(watchOSApplicationExtension 10.0, *) {
        var daysToAddString = ""
        if (includeFirstDay) {
            daysToAddString = "\(getLocalizedDay(days: daysToAdd, localizationManager: localizationManager))"
        } else {
            daysToAddString = "\(daysToAdd)"
        }
        
        if (includeFirstDay){
            return daysToAddString + localizationManager.localize(.day)
        }else{
            if (localizationManager.localize(.localeCode) == "en" && daysToAdd == 1) {
                return daysToAddString + "day later"
            } else {
                return daysToAddString + localizationManager.localize(.daysLater)
            }
        }
    }else{
        return " (\(daysToAdd)" + (includeFirstDay ? localizationManager.localize(.widgetDay) : localizationManager.localize(.widgetDaysLater)) + ")"
    }
    
}

func formatWidgetDate(date: Date, localizationManager: LocalizationManager) -> String {
    let formatter = DateFormatter()
    switch localizationManager.localize(.localeCode) {
    case "ja":
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        break;
    case "en":
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d"
        break;
    default:
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d"
        break;
    }
    
    return formatter.string(from: date);
}

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

struct AccessoryCornerView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    var futureDate: Date
    var daysToAdd: Int
    var includeFirstDay: Bool
    
    var body: some View {
        if #available(watchOSApplicationExtension 10.0, *) {
            Text(formatWidgetDate(date: futureDate, localizationManager: localizationManager))
                .scaledToFit()
                .widgetCurvesContent()
                .widgetLabel(getDaysToAddStrings(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay, localizationManager: localizationManager))
                .containerBackground(for: .widget, alignment: .bottom){}
        } else {
            Image(systemName: "calendar.badge.clock")
                .resizable()
                .scaledToFit()
                .padding(5)
                .widgetLabel {
                    Text(formatWidgetDate(date: futureDate, localizationManager: localizationManager) + getDaysToAddStrings(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay, localizationManager: localizationManager))
                        .minimumScaleFactor(0.4)
                }
        }
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
        .supportedFamilies([.accessoryCorner])
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

