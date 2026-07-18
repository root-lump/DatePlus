import DatePlusCore
import SwiftUI

struct LegacyNavigationView: View {
    @Environment(\.locale) private var locale
    @State private var selection = 0

    private var localizer: AppLocalizer { AppLocalizer(locale: locale) }

    var body: some View {
        TabView(selection: $selection) {
            CalculatorView()
                .tag(0)

            NavigationView {
                PinnedDaysView()
            }
            .tag(1)
        }
        .tabViewStyle(.page)
        .onOpenURL { url in
            if url.opensPinnedDays { selection = 1 }
        }
        .accessibilityLabel(localizer.text(.calculate))
    }
}
