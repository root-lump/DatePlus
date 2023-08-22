import SwiftUI
import WidgetKit

// This is a SwiftUI View that displays a list of "pinned" days.
struct PinnedDaysView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage("pinnedDays") private var pinnedDaysData: Data = Data() // pinnedDay data store
    
    @State private var nowDate: Date = Date()   // current date
    @State private var pinnedDays: [DayInfo] = []   // pinnedDay store
    // This is a state property wrapper that will store the alert item.
    @State private var alertItem: AlertItem?
    
    // The body of the SwiftUI view.
    var body: some View {
        // A list view that displays each pinned day.
        List {
            if pinnedDays.isEmpty {
                // message when not pinned
                Text("There are no days pinned.")
                    .foregroundColor(.secondary)
                    .font(.headline)
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                    .padding()
                Text("Pinned Day Tip")
                    .foregroundColor(.secondary)
                    .font(.caption2)
                    .minimumScaleFactor(0.5)
                    .lineLimit(6)
                    .padding()
            }
            // For each pinned day...
            ForEach(pinnedDays, id: \.self) { dayInfo in
                HStack {
                    // With a vertical stack view on the left...
                    VStack(alignment: .leading) {
                        // Change the display by includeFirstDay.
                        if (dayInfo.includeFirstDay) {
                            Text("\(dayInfo.days.localizedString) \(Text("day"))")
                                .foregroundColor(.secondary)
                        } else {
                            if (String(localized: "Locale Code") == "en" && dayInfo.days == 1) {
                                Text("\(dayInfo.days) day later")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(dayInfo.days) \(Text("days later"))")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        // Display the formatted date.
                        Text(formatDate(calculateDate(date: nowDate, daysToAdd: dayInfo.days, includeFirstDay: dayInfo.includeFirstDay)))
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
                    Spacer()
                }
                // Add swipe actions to the horizontal stack view.
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // The delete button.
                    Button(action: {
                        alertItem = AlertItem(type: .delete(dayInfo))
                    }) {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    .tint(.red)
                    // The add to complication button.
                    Button(action: {
                        alertItem = AlertItem(type: .addToComplication(dayInfo))
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
                    title: Text("Are you sure you want to delete?"),
                    message: nil,
                    primaryButton: .destructive(Text("Delete"), action: {
                        removePinnedDay(dayInfo: dayInfo)
                        resetAlertItem()
                    }),
                    secondaryButton: .cancel(Text("Cancel"), action:{
                        resetAlertItem()
                    })
                )
            case .addToComplication(let dayInfo):
                return Alert(
                    title: Text("Do you want to update the Complication?"),
                    message: nil,
                    primaryButton: .default(Text("Cancel"), action: {
                        resetAlertItem()
                    }),
                    secondaryButton: .default(Text("Update"), action: {
                        registerComplication(daysToAdd: dayInfo.days, includeFirstDay: dayInfo.includeFirstDay)
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
    
    // Function to register a complication.
    func registerComplication(daysToAdd: Int, includeFirstDay: Bool) {
        let userDefaults = UserDefaults(suiteName: "group.net.root-lump.date-plus")
        userDefaults?.set(daysToAdd, forKey: "daysToAdd")
        userDefaults?.set(includeFirstDay, forKey: "includeFirstDay")
        userDefaults?.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct PinnedDaysPreview: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            PinnedDaysView()
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
