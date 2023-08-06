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
            // For each pinned day...
            ForEach(pinnedDays, id: \.self) { dayInfo in
                HStack {
                    // With a vertical stack view on the left...
                    VStack(alignment: .leading) {
                        // Change the display by includeFirstDay.
                        Text("\(dayInfo.days) \(dayInfo.includeFirstDay ? "日目" : "日後")")
                            .foregroundColor(.secondary)
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
                        Label("削除", systemImage: "trash.fill")
                    }
                    .tint(.red)
                    // The add to complication button.
                    Button(action: {
                        alertItem = AlertItem(type: .addToComplication(dayInfo))
                    }) {
                        Label("コンプリケーションに追加", systemImage: "watchface.applewatch.case")
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
                    title: Text("削除してもよろしいですか？"),
                    message: nil,
                    primaryButton: .destructive(Text("削除"), action: {
                        removePinnedDay(dayInfo: dayInfo)
                        resetAlertItem()
                    }),
                    secondaryButton: .cancel(Text("キャンセル"), action:{
                        resetAlertItem()
                    })
                )
            case .addToComplication(let dayInfo):
                return Alert(
                    title: Text("コンプリケーションを更新しますか？"),
                    message: nil,
                    primaryButton: .default(Text("キャンセル"), action: {
                        resetAlertItem()
                    }),
                    secondaryButton: .default(Text("更新"), action: {
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
        PinnedDaysView()
    }
}
