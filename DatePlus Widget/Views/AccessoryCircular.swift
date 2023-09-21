import SwiftUI
import WidgetKit

struct AccessoryCircularView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    var futureDate: Date
    var daysToAdd: Int
    var includeFirstDay: Bool
    
    var body: some View {
        if #available(watchOSApplicationExtension 10, *) {
            Image("CircleAppIcon")
                .resizable()
                .scaledToFit()
                .containerBackground(for: .widget, alignment: .bottom){}
        } else {
            Image("AppIcon")
                .resizable()
                .scaledToFit()
        }
    }
}

struct AccessoryCircularPreviews: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            AccessoryCircularView(localizationManager: LocalizationManager(id), futureDate: Date(), daysToAdd: 3, includeFirstDay: false)
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
