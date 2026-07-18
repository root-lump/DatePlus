import SwiftUI

struct RootView: View {
    @StateObject private var model = AppModel()
    private let locale: Locale

    init(locale: Locale? = nil) {
        let language = Bundle.main.preferredLocalizations.first
        self.locale = locale ?? language.map { Locale(identifier: $0) } ?? .current
    }

    var body: some View {
        Group {
            if #available(watchOS 10, *) {
                ModernNavigationView()
            } else {
                LegacyNavigationView()
            }
        }
        .environmentObject(model)
        .environment(\.locale, locale)
    }
}

#Preview("English") {
    RootView(locale: Locale(identifier: "en"))
}

#Preview("Japanese") {
    RootView(locale: Locale(identifier: "ja"))
}
