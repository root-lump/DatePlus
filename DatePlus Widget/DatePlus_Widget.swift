
import WidgetKit
import SwiftUI

func calculateDate(daysToAdd: Int, includeFirstDay: Bool) -> Date {
    let currentDate = Date()
    let addNum = daysToAdd - (includeFirstDay ? 1 : 0)
    return Calendar.current.date(byAdding: .day, value: addNum, to: currentDate) ?? currentDate
}

extension Int {
    var ordinal: String {
        switch self {
        case 1: return "1st "
        case 2: return "2nd "
        case 3: return "3rd "
        default:
            return "\(self)th "
        }
    }
}

extension Int {
    var localizedString: String {
        if (String(localized: "Locale Code") == "en") {
            return self.ordinal
        } else {
            return "\(self)"
        }
    }
}

func getDaysToAddStrings(daysToAdd: Int, includeFirstDay: Bool, localeCode: String) -> String {
    if #available(watchOSApplicationExtension 10.0, *) {
        var daysToAddString = ""
        if (includeFirstDay) {
            daysToAddString = "\(daysToAdd.localizedString)"
        } else {
            daysToAddString = "\(daysToAdd)"
        }
        
        if (includeFirstDay){
            return daysToAddString + String(localized: "day")
        }else{
            if (localeCode == "en" && daysToAdd == 1) {
                return daysToAddString + String(localized: "day later")
            } else {
                return daysToAddString + String(localized: "days later")
            }
        }
    }else{
        return " (\(daysToAdd)" + (includeFirstDay ? String(localized: "widget_day") : String(localized: "widget_days later")) + ")"
    }

}

func formatWidgetDate(date: Date, localeCode: String) -> String {
    let formatter = DateFormatter()
    switch localeCode {
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
        formatter.dateFormat = "E, MMMM d, yyyy"
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
    var localeCode = String(localized: "Locale Code")
    var futureDate: Date
    var daysToAdd: Int
    var includeFirstDay: Bool
    
    var body: some View {
        if #available(watchOSApplicationExtension 10.0, *) {
            Text(formatWidgetDate(date: futureDate, localeCode: localeCode))
                .scaledToFit()
                .widgetCurvesContent()
                .widgetLabel(getDaysToAddStrings(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay, localeCode: localeCode))
            .containerBackground(for: .widget, alignment: .bottom){}
        } else {
            Image(systemName: "calendar.badge.clock")
                .resizable()
                .scaledToFit()
                .padding(5)
                .widgetLabel {
                    Text(formatWidgetDate(date: futureDate, localeCode: localeCode) + getDaysToAddStrings(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay, localeCode: localeCode))
                        .minimumScaleFactor(0.4)
                }
        }
    }
}

struct DatePlusComplicationView: View {
    var localeCode = String(localized: "Locale Code")
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
            AccessoryCornerView(localeCode: localeCode, futureDate: futureDate, daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
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
            DatePlusComplicationView(localeCode: id, entry: DateCounterEntry(date: Date(), daysToAdd: 1, includeFirstDay: false))
                .previewContext(WidgetPreviewContext(family: .accessoryCorner))
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}

