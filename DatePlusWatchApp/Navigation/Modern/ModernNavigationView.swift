import DatePlusCore
import SwiftUI

@available(watchOS 10, *)
struct ModernNavigationView: View {
    @Environment(\.locale) private var locale
    @State private var isPinnedDaysPresented = false

    private var localizer: AppLocalizer { AppLocalizer(locale: locale) }

    var body: some View {
        NavigationStack {
            CalculatorView(showsInlinePinButton: false)
                .containerBackground(.gray.gradient, for: .navigation)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isPinnedDaysPresented = true
                        } label: {
                            Image(systemName: "list.bullet")
                        }
                        .accessibilityLabel(localizer.text(.pinList))
                    }
                }
                .sheet(isPresented: $isPinnedDaysPresented) {
                    NavigationStack {
                        PinnedDaysView()
                    }
                }
        }
        .onOpenURL { url in
            if url.opensPinnedDays { isPinnedDaysPresented = true }
        }
    }
}
