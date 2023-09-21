import SwiftUI
import WidgetKit

@available(watchOS 10, *)
struct WatchOS10_RegisterComplication: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    var dayInfo: DayInfo
    @Binding var sheetItem: W10_SheetItem?
    
    let screenHeight = WKInterfaceDevice.current().screenBounds.height
    let screenWidth = WKInterfaceDevice.current().screenBounds.width
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(localizationManager.localize(.addWatchFace))
                    .font(.title3)
                    .fontWeight(.black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding()
                
                getDaysToAddText(localizationManager: localizationManager, dayInfo: dayInfo)
                    .font(.title2)
                    .fontWeight(.black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                Text(localizationManager.localize(.selectWidgetNumber))
                    .font(.caption)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding()
                Spacer()
                
            }.toolbar {
                ToolbarItemGroup(placement: .bottomBar){
                    Button {
                        registerComplication(number: 1, dayInfo: dayInfo)
                        WidgetCenter.shared.reloadTimelines(ofKind: "[1]")
                        sheetItem = nil
                    } label: {
                        Text("1")
                    }.controlSize(.large)
                        .background(.orange, in: Capsule())
                    
                    Button {
                        registerComplication(number: 2, dayInfo: dayInfo)
                        WidgetCenter.shared.reloadTimelines(ofKind: "[2]")
                        sheetItem = nil
                    } label: {
                        Text("2")
                    }
                    .controlSize(.large)
                    .background(.orange, in: Capsule())
                    
                    Button {
                        registerComplication(number: 3, dayInfo: dayInfo)
                        WidgetCenter.shared.reloadTimelines(ofKind: "[3]")
                        sheetItem = nil
                    } label: {
                        Text("3")
                    }.controlSize(.large)
                        .background(.orange, in: Capsule())
                }
            }.containerBackground(.orange.gradient,
                                  for: .navigation)
        }
    }
}

@available(watchOS 10, *)
struct WatchOS10_RegisterComplicationPreviews: PreviewProvider {
    @State static var pinnedDay = DayInfo(days: 5, includeFirstDay: true)
    @State static var sheetItem: W10_SheetItem? = W10_SheetItem(type: .addToComplication(pinnedDay))
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            WatchOS10_RegisterComplication(localizationManager: LocalizationManager(id), dayInfo: pinnedDay, sheetItem: $sheetItem)
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
