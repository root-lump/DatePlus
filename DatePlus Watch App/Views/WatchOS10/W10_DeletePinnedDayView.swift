import SwiftUI

@available(watchOS 10, *)
struct WatchOS10_DeletePinnedDayView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    @Binding var pinnedDays: [DayInfo]
    var dayInfo: DayInfo
    @Binding var sheetItem: W10_SheetItem?
    
    let screenHeight = WKInterfaceDevice.current().screenBounds.height
    let screenWidth = WKInterfaceDevice.current().screenBounds.width
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(localizationManager.localize(.confirmDelete))
                    .font(.title3)
                    .fontWeight(.black)
                    .minimumScaleFactor(0.8)
                    .lineLimit(3)
                    .padding()
                
                getDaysToAddText(localizationManager: localizationManager, dayInfo: dayInfo)
                    .font(.title2)
                    .fontWeight(.black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                Spacer()
                
            }.toolbar {
                ToolbarItemGroup(placement: .bottomBar){
                    Button {
                        pinnedDays = removePinnedDay(dayInfo: dayInfo)
                        sheetItem = nil
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text(localizationManager.localize(.delete))
                                .font(.title3)
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        }.padding()
                    }.controlSize(.large)
                        .background(.red, in: Capsule())
                }
            }.containerBackground(.red.gradient,
                                  for: .navigation)
        }
    }
}

@available(watchOS 10, *)
struct WatchOS10_DeletePinnedDayViewPreviews: PreviewProvider {
    @State static var dayInfo = DayInfo(days: 5, includeFirstDay: true)
    @State static var pinnedDays = [dayInfo, dayInfo]
    @State static var sheetItem: W10_SheetItem? = W10_SheetItem(type: .delete(dayInfo))
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            WatchOS10_DeletePinnedDayView(localizationManager: LocalizationManager(id), pinnedDays: $pinnedDays, dayInfo: dayInfo, sheetItem: $sheetItem)
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
