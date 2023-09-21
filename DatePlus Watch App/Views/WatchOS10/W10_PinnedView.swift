import SwiftUI
import WidgetKit

// This is a SwiftUI View that displays a list of "pinned" days.
@available(watchOS 10, *)
struct WatchOS10_PinnedView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    @Environment(\.scenePhase) private var scenePhase
    @Binding var pinnedDays: [DayInfo]
    @State private var nowDate: Date = Date()   // current date
    // This is a state property wrapper that will store the alert item.
    @State private var alertItem: W10_AlertItem?
    @State private var refresh: Bool = false
    @State var selectedPinned: DayInfo?
    
    // The body of the SwiftUI view.
    var body: some View {
        NavigationSplitView {
            Text(localizationManager.localize(.pinList))
                .font(.headline)
            // A list view that displays each pinned day.
            List(selection: $selectedPinned) {
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
                } else {
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
                        // Add swipe actions.
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            // The delete button.
                            Button(action: {
                                alertItem = W10_AlertItem(type: .delete(dayInfo))
                            }) {
                                Label("Delete", systemImage: "trash.fill")
                            }
                            .tint(.red)
                            // The add to complication button.
                            Button(action: {
                                alertItem = W10_AlertItem(type: .addToComplication(dayInfo))
                            }) {
                                Label("Add to Complications", systemImage: "watchface.applewatch.case")
                            }
                            .tint(.orange)
                            
                        }
                    }
                }
            }
            // When the view appears, load the pinned days.
            .onAppear {
                pinnedDays = getAllPinnedDays()
            }
            // Display an alert when the alertItem state changes.
            .alert(item: $alertItem) { alertItem in
                switch alertItem.type {
                case .delete(let dayInfo):
                    return Alert(
                        title: Text(localizationManager.localize(.confirmDelete)),
                        message: nil,
                        primaryButton: .destructive(Text(localizationManager.localize(.delete)), action: {
                            pinnedDays = removePinnedDay(dayInfo: dayInfo)
                            refresh.toggle()
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
                            registerComplication(daysToAdd: dayInfo.days, includeFirstDay: dayInfo.includeFirstDay)
                            resetAlertItem()
                        })
                    )
                }
            }
        } detail: {
            W10_RegisterComplication(localizationManager: localizationManager, dayInfo: $selectedPinned)
        }
        
    }
    
    // Function to reset the alert item.
    func resetAlertItem() {
        alertItem = nil
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

@available(watchOS 10, *)
struct WatchOS10_PinnedViewPreview: PreviewProvider {
    @State static var pinnedDays = getAllPinnedDays()
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            WatchOS10_PinnedView(localizationManager: LocalizationManager(id), pinnedDays: $pinnedDays)
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
