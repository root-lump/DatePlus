import SwiftUI
import WidgetKit

// This is a SwiftUI View that displays a list of "pinned" days.
struct WatchOS9_PinnedView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage("pinnedDays") private var pinnedDaysData: Data = Data() // pinnedDay data store
    
    @State private var nowDate: Date = Date()   // current date
    @State private var pinnedDays: [DayInfo] = []   // pinnedDay store
    // This is a state property wrapper that will store the alert item.
    @State private var alertItem: W9_AlertItem?
    
    // The body of the SwiftUI view.
    var body: some View {
        // A list view that displays each pinned day.
        List {
            if pinnedDays.isEmpty {
                // message when not pinned
                Text(localizationManager.localize(.pinnedNothing))
                    .foregroundColor(.secondary)
                    .font(.headline)
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                    .padding()
                Text(localizationManager.localize(.pinnedTip))
                    .foregroundColor(.secondary)
                    .font(.caption2)
                    .minimumScaleFactor(0.5)
                    .lineLimit(6)
                    .padding()
            }
            // For each pinned day...
            ForEach(pinnedDays, id: \.self) { dayInfo in
                // With a vertical stack view on the left...
                VStack(alignment: .leading) {
                    getDaysToAddText(localizationManager: localizationManager, dayInfo: dayInfo)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    // Display the formatted date.
                    Text(formatDate(date: calculateDate(date: nowDate, daysToAdd: dayInfo.days, includeFirstDay: dayInfo.includeFirstDay), localizationManager: localizationManager))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    // When the view appears, load the pinned days.
                        .onAppear {
                            nowDate = Date()
                        }
                    // When App goes foreground
                        .onChange(of: scenePhase) { phase in
                            if phase == .active {
                                nowDate = Date()
                            }
                        }
                }
                .padding(8)
                // Add swipe actions to the horizontal stack view.
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // The delete button.
                    Button(action: {
                        alertItem = W9_AlertItem(type: .delete(dayInfo))
                    }) {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    .tint(.red)
                    // The add to complication button.
                    Button(action: {
                        alertItem = W9_AlertItem(type: .addToComplication(dayInfo))
                    }) {
                        Label("Add to Complications", systemImage: "watchface.applewatch.case")
                    }
                    .tint(.orange)
                    
                }
            }
        }
        // When the view appears, load the pinned days.
        .onAppear {
            loadPinnedDays()
        }
        // Display an alert when the alertItem state changes.
        .alert(item: $alertItem) { alertItem in
            switch alertItem.type {
            case .delete(let dayInfo):
                return Alert(
                    title: Text(localizationManager.localize(.confirmDelete)),
                    message: nil,
                    primaryButton: .destructive(Text(localizationManager.localize(.delete)), action: {
                        removePinnedDay(dayInfo: dayInfo)
                        resetAlertItem()
                    }),
                    secondaryButton: .cancel(Text(localizationManager.localize(.cancel)), action:{
                        resetAlertItem()
                    })
                )
            case .addToComplication(let dayInfo):
                return Alert(
                    title: Text(localizationManager.localize(.confirmComplication)),
                    message: nil,
                    primaryButton: .default(Text(localizationManager.localize(.cancel)), action: {
                        resetAlertItem()
                    }),
                    secondaryButton: .default(Text(localizationManager.localize(.update)), action: {
                        registerComplication(number: 1, dayInfo: dayInfo)
                        WidgetCenter.shared.reloadTimelines(ofKind: "[1]")
                        resetAlertItem()
                    })
                )
            }
        }
        
    }
    
    // Function to reset the alert item.
    func resetAlertItem() {
        alertItem = nil
    }
    
    // Function to remove a pinned day.
    func removePinnedDay(dayInfo: DayInfo) {
        pinnedDays.removeAll { $0 == dayInfo }
        savePinnedDays()
    }
    
    // Function to load the pinned days from AppStorage.
    func loadPinnedDays() {
        if let loadedDays = try? JSONDecoder().decode([DayInfo].self, from: pinnedDaysData) {
            pinnedDays = loadedDays.map { dayInfo in
                DayInfo(days: dayInfo.days, includeFirstDay: dayInfo.includeFirstDay)
            }
            savePinnedDays()
        }
    }
    
    // Function to save the pinned days to AppStorage.
    func savePinnedDays() {
        if let encodedData = try? JSONEncoder().encode(pinnedDays) {
            pinnedDaysData = encodedData
        }
    }
}

struct WatchOS9_PinnedViewPreview: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            WatchOS9_PinnedView(localizationManager: LocalizationManager(id))
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
