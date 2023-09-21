import SwiftUI

struct SwitchOS: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    
    var body: some View {
        if #available(watchOS 10, *) {
            WatchOS10_NavigationStackView(localizationManager: localizationManager)
        } else {
            WatchOS9_TabView(localizationManager: localizationManager)
        }
    }
}

struct SwitchOSPreview: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            SwitchOS(localizationManager: LocalizationManager(id))
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
