import WidgetKit
import SwiftUI

struct AccessoryInlineView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    var futureDate: Date
    var daysToAdd: Int
    var includeFirstDay: Bool
    
    var body: some View {
        Text(formatWidgetDate(date: futureDate, localizationManager: localizationManager) + " ( " + getDaysToAddStrings(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay, localizationManager: localizationManager) + " )")
            .minimumScaleFactor(0.4)
    }
}

struct AccessoryInlinePreviews: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            AccessoryInlineView(localizationManager: LocalizationManager(id), futureDate: Date(), daysToAdd: 3, includeFirstDay: false)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
