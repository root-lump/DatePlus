import SwiftUI
import WatchKit

struct ContentView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    @State private var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            MainView(localizationManager: localizationManager)
                .tabItem {
                    Text("Calculate")
                }
                .tag(0)
            
            PinnedDaysView(localizationManager: localizationManager)
                .tabItem {
                    Text("Pinned Item")
                }
                .tag(1)
        }.onOpenURL { url in
            handleDeepLink(url)
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == "dateplus",
              components.host == "deeplink",
              let from = components.queryItems?.first(where: { $0.name == "from" })?.value,
              from == "widget" else {
            return
        }
        
        // Transition to PinnedDaysView by handling deep links from widgets
        selection = 1
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
