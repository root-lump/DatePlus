import DatePlusCore
import SwiftUI

@available(watchOS 10, *)
struct ModernNavigationView: View {
    @Environment(\.locale) private var locale
    @State private var path: [Destination] = []

    private var localizer: AppLocalizer { AppLocalizer(locale: locale) }

    var body: some View {
        NavigationStack(path: $path) {
            CalculatorView()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            path.append(.pinnedDays)
                        } label: {
                            Image(systemName: "pin.circle")
                        }
                        .accessibilityLabel(localizer.text(.pinList))
                    }
                }
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case .pinnedDays:
                        PinnedDaysView()
                    }
                }
        }
        .onOpenURL { url in
            if url.opensPinnedDays { path = [.pinnedDays] }
        }
    }
}

@available(watchOS 10, *)
private enum Destination: Hashable {
    case pinnedDays
}
