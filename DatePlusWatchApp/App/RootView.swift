import SwiftUI

struct RootView: View {
    @StateObject private var model = AppModel()

    var body: some View {
        Group {
            if #available(watchOS 10, *) {
                ModernNavigationView()
            } else {
                LegacyNavigationView()
            }
        }
        .environmentObject(model)
    }
}

#Preview("English") {
    RootView()
        .environment(\.locale, Locale(identifier: "en"))
}

#Preview("Japanese") {
    RootView()
        .environment(\.locale, Locale(identifier: "ja"))
}
