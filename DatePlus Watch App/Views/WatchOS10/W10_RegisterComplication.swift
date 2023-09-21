import SwiftUI

@available(watchOS 10, *)
struct W10_RegisterComplication: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    @State private var pinnedDays = getAllPinnedDays()
    @Binding var dayInfo: DayInfo?
    
    let screenHeight = WKInterfaceDevice.current().screenBounds.height
    let screenWidth = WKInterfaceDevice.current().screenBounds.width
    
    var body: some View {
        TabView(selection: $dayInfo) {
            ForEach(pinnedDays) { pinnedDay in
                VStack {
                    Text(localizationManager.localize(.addWatchFace))
                        .font(.title3)
                        .fontWeight(.black)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding()
                    
                    getDaysToAddText(localizationManager: localizationManager, dayInfo: pinnedDay)
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
                            // Perform an action here.
                        } label: {
                            Text("1")
                        }.controlSize(.large)
                            .background(.blue, in: Capsule())
                        
                        Button {
                            // Perform an action here.
                        } label: {
                            Text("2")                        }
                        .controlSize(.large)
                        .background(.blue, in: Capsule())
                        
                        Button {
                            // Perform an action here.
                        } label: {
                            Text("3")
                        }.controlSize(.large)
                            .background(.blue, in: Capsule())
                    }
                }
                .tag(Optional(pinnedDay))
                .containerBackground(.blue.gradient,
                                     for: .tabView)
            }
        }
        .tabViewStyle(.verticalPage(transitionStyle: .blur))
    }
}

@available(watchOS 10, *)
struct W10_RegisterComplicationPreviews: PreviewProvider {
    @State static var pinnedDay = getAllPinnedDays().first
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            W10_RegisterComplication(localizationManager: LocalizationManager(id), dayInfo: $pinnedDay)
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
