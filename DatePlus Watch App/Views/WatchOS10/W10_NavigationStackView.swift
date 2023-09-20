import SwiftUI

@available(watchOS 10, *)
struct WatchOS10_NavigationStackView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    @State private var isPresented = false
    
    var body: some View {
        NavigationStack {
            WatchOS10_MainView(localizationManager: localizationManager)
                .containerBackground(.blue.gradient,
                                     for: .navigation)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isPresented = true
                        } label: {
                            Image(systemName:"list.bullet")
                        }.sheet(isPresented: $isPresented) {
                            WatchOS10_PinnedView(localizationManager: localizationManager)
                        }
                    }
                }
        }
        .onOpenURL(perform: { url in
            handleDeepLink(url)
        })
    }
    
    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == "dateplus",
              components.host == "deeplink",
              let from = components.queryItems?.first(where: { $0.name == "from" })?.value,
              from == "widget" else {
            return
        }
        
        isPresented = true
    }
}

@available(watchOS 10, *)
struct WatchOS10_NavigationStackViewPreviews: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            WatchOS10_NavigationStackView(localizationManager: LocalizationManager(id))
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
