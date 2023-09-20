import WidgetKit
import SwiftUI

struct AccessoryRectangularView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    var futureDate: Date
    var daysToAdd: Int
    var includeFirstDay: Bool
    
    var body: some View {
        if #available(watchOSApplicationExtension 10.0, *) {
            VStack {
                Text(getDaysToAddStrings(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay, localizationManager: localizationManager))
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Text(formatDate(date: futureDate, localizationManager: localizationManager))
                    .font(.headline)
                    .minimumScaleFactor(0.5)
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .containerBackground(for: .widget, alignment: .bottom){
                Image("DatePlusBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .brightness(-0.5)
                    .contrast(0.5)
            }
        } else {
            VStack {
                
                Text(getDaysToAddStrings(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay, localizationManager: localizationManager))
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Text(formatDate(date: futureDate, localizationManager: localizationManager))
                    .font(.headline)
                    .minimumScaleFactor(0.5)
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }
}

struct AccessoryRectangularPreviews: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            AccessoryRectangularView(localizationManager: LocalizationManager(id), futureDate: Date(), daysToAdd: 3, includeFirstDay: false)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
