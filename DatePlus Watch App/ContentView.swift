import SwiftUI
import WatchKit

struct ContentView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    
    var body: some View {
        SwitchOS(localizationManager: localizationManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            ContentView(localizationManager: LocalizationManager(id))
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
