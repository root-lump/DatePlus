import SwiftUI

// A struct to represent an alert item, which has a unique ID and a type
struct W10_AlertItem: Identifiable {
    let id = UUID()
    let type: W10_AlertType
}

// An enum to represent the type of alert, which can be either 'delete' or 'addToComplication'
enum W10_AlertType {
    case delete(DayInfo)
    case addToComplication(DayInfo)
}

// The main view of the app
@available(watchOS 10, *)
struct WatchOS10_MainView: View {
    var localizationManager = LocalizationManager(String(localized: "Locale Code"))
    // App storage properties to store user preferences
    @AppStorage("daysToAdd") private var daysToAdd = 1
    @State private var futureDate = Date()
    @AppStorage("pinnedDays") private var pinnedDaysData: Data = Data()
    @AppStorage("includeFirstDay") private var includeFirstDay = false
    @State private var showAlert = false
    @State private var alertMessage = Text("")
    
    var body: some View {
        NavigationStack {
            // Binding to update the future date whenever the number of days to add changes
            let daysBinding = Binding<Int>(
                get: { self.daysToAdd },
                set: {
                    self.daysToAdd = $0
                    self.futureDate = calculateDate(daysToAdd: self.daysToAdd, includeFirstDay: self.includeFirstDay)
                }
            )
            
            let screenHeight = WKInterfaceDevice.current().screenBounds.height
            let screenWidth = WKInterfaceDevice.current().screenBounds.width
            
            // The main view layout
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Picker("", selection: daysBinding) {
                        ForEach(1 ..< 151, id: \.self) { num in     // Repeat by id
                            if (includeFirstDay) {
                                Text("\(getLocalizedDay(days: num, localizationManager: localizationManager))")
                                    .font(.largeTitle)
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                            } else {
                                Text("\(num)")
                                    .font(.largeTitle)
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .frame(width: screenWidth/1.8)
                    .labelsHidden()
                    .pickerStyle(WheelPickerStyle())
                    
                    Spacer()
                    
                    if (includeFirstDay){
                        Text(localizationManager.localize(.day))
                            .font(.title)
                            .minimumScaleFactor(0.4)
                            .lineLimit(2)
                    }else{
                        if (localizationManager.localize(.localeCode) == "en" && daysToAdd == 1) {
                            Text("day\nlater")
                                .font(.title)
                                .minimumScaleFactor(0.4)
                                .lineLimit(2)
                        } else {
                            Text(localizationManager.localize(.daysLater))
                                .font(.title)
                                .minimumScaleFactor(0.4)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                }
                .frame(height: screenHeight*0.225)
                .padding(.vertical, 5) // Add vertical padding
                
                Text(" \(formatDate(date: futureDate, localizationManager: localizationManager))")
                    .frame(height: screenHeight*0.175)
                    .font(.title3)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                    Button(action: {
                        includeFirstDay.toggle()
                        futureDate = calculateDate(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
                    }) {
                        Text(localizationManager.localize(.fromToday))
                            .font(.headline)
                            .minimumScaleFactor(0.4)
                            .lineLimit(1)
                            .frame(minWidth: screenWidth*0.4, maxWidth: screenWidth*0.5, minHeight: screenHeight*0.2, maxHeight: screenHeight*0.2)
                            .foregroundColor(includeFirstDay ? .black : .white) // Set text color
                    }
                    .background(includeFirstDay ? Color.white : Color.clear)
                    .cornerRadius(50)
                    .frame(minWidth: screenWidth*0.4, maxWidth: screenWidth*0.65, minHeight: screenHeight*0.2, maxHeight: screenHeight*0.2)
            }.onAppear {
                futureDate = calculateDate(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
                
            }.toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        pinDays()
                    } label: {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.white)
                    }.alert(isPresented: $showAlert) {
                        Alert(title: alertMessage)
                    }.fixedSize()
                }
            }
        }
    }
    
    // Function to pin the days
    func pinDays() {
        var days = (try? JSONDecoder().decode([DayInfo].self, from: pinnedDaysData)) ?? []
        let newDayInfo = DayInfo(days: daysToAdd, includeFirstDay: includeFirstDay)
        if days.contains(newDayInfo) {
            alertMessage = Text(localizationManager.localize(.alreadyRegistered))
        } else {
            days.append(newDayInfo)
            if let encodedData = try? JSONEncoder().encode(days) {
                pinnedDaysData = encodedData
            }
            alertMessage = Text(localizationManager.localize(.pinned))
        }
        showAlert = true
    }
}

@available(watchOS 10, *)
struct WatchOS10_MainViewPreview: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            WatchOS10_MainView(localizationManager: LocalizationManager(id))
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}

