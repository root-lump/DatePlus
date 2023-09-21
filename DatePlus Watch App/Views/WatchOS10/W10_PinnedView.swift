import SwiftUI

// A struct to represent an alert item, which has a unique ID and a type
struct W10_SheetItem: Identifiable {
    let id = UUID()
    let type: W10_SheetType
}

// An enum to represent the type of alert, which can be either 'delete' or 'addToComplication'
enum W10_SheetType {
    case delete(DayInfo)
    case addToComplication(DayInfo)
}

// This is a SwiftUI View that displays a list of "pinned" days.
@available(watchOS 10, *)
struct WatchOS10_PinnedView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    @Environment(\.scenePhase) private var scenePhase
    @Binding var pinnedDays: [DayInfo]
    @State private var nowDate: Date = Date()   // current date
    // This is a state property wrapper that will store the sheet item.
    @State private var sheetItem: W10_SheetItem?
    
    // The body of the SwiftUI view.
    var body: some View {
        NavigationStack {
            // A list view that displays each pinned day.
            List() {
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            // The delete button.
                            Button(action: {
                                sheetItem = W10_SheetItem(type: .delete(dayInfo))
                            }) {
                                Label("Delete", systemImage: "trash.fill")
                            }
                            .tint(.red)
                        }.swipeActions(edge: .leading, allowsFullSwipe: true){
                            // The add to complication button.
                            Button(action: {
                                sheetItem = W10_SheetItem(type: .addToComplication(dayInfo))
                            }) {
                                Label("Add to Complications", systemImage: "watchface.applewatch.case")
                            }
                            .tint(.orange)
                        }
                    }.sheet(item: $sheetItem) { sheetItem in
                        switch sheetItem.type {
                        case .delete(let dayInfo):
                            WatchOS10_DeletePinnedDayView(localizationManager: localizationManager, pinnedDays: $pinnedDays, dayInfo: dayInfo, sheetItem: $sheetItem)
                        case .addToComplication(let dayInfo):
                            WatchOS10_RegisterComplication(localizationManager: localizationManager, dayInfo: dayInfo, sheetItem: $sheetItem)
                        }
                        
                    }
                }
            }
            // When the view appears, load the pinned days.
            .onAppear {
                pinnedDays = getAllPinnedDays()
            }.navigationTitle(localizationManager.localize(.pinList))
                .navigationBarTitleDisplayMode(.automatic)
        }
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
