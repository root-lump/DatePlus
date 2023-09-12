import WidgetKit
import SwiftUI

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

struct AccessoryCornerPreviews: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            AccessoryCornerView(localizationManager: LocalizationManager(id), futureDate: Date(), daysToAdd: 3, includeFirstDay: false)
                .previewContext(WidgetPreviewContext(family: .accessoryCorner))
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
