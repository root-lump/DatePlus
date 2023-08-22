import SwiftUI

// A struct to represent an alert item, which has a unique ID and a type
struct AlertItem: Identifiable {
    let id = UUID()
    let type: AlertType
}

// An enum to represent the type of alert, which can be either 'delete' or 'addToComplication'
enum AlertType {
    case delete(DayInfo)
    case addToComplication(DayInfo)
}

extension Int {
    var ordinal: String {
        switch self {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default:
            return "\(self)th"
        }
    }
}

extension Int {
    var localizedString: String {
        if (String(localized: "Locale Code") == "en") {
            return self.ordinal
        } else {
            return "\(self)"
        }
    }
}

// The main view of the app
struct MainView: View {
    // App storage properties to store user preferences
    @AppStorage("daysToAdd") private var daysToAdd = 1
    @State private var futureDate = Date()
    @AppStorage("pinnedDays") private var pinnedDaysData: Data = Data()
    @AppStorage("includeFirstDay") private var includeFirstDay = false
    @State private var showAlert = false
    @State private var alertMessage = Text("")
    
    var body: some View {
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
                            Text("\(num.localizedString)")
                                .font(.largeTitle)
                                .minimumScaleFactor(0.6)
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
                    Text("day")
                        .font(.title)
                        .minimumScaleFactor(0.4)
                        .lineLimit(2)
                }else{
                    if (String(localized: "Locale Code") == "en" && daysToAdd == 1) {
                        Text("day\nlater")
                            .font(.title)
                            .minimumScaleFactor(0.4)
                            .lineLimit(2)
                    } else {
                        Text("days later")
                            .font(.title)
                            .minimumScaleFactor(0.4)
                            .lineLimit(2)
                    }
                }
                Spacer()
            }
            .frame(height: screenHeight*0.225)
            .padding(.vertical, 5) // Add vertical padding
            
            Text(" \(formatDate(futureDate))")
                .frame(width: .infinity, height: screenHeight*0.175)
                .font(.title3)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            
            HStack {
                Spacer()
                Button(action: {
                    includeFirstDay.toggle()
                    futureDate = calculateDate(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
                }) {
                    Text("From Today")
                        .font(.headline)
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .frame(minWidth: screenWidth*0.4, maxWidth: screenWidth*0.5, minHeight: screenHeight*0.2, maxHeight: screenHeight*0.2)
                        .foregroundColor(includeFirstDay ? .black : .white) // Set text color
                }
                .background(includeFirstDay ? Color.white : Color.clear)
                .cornerRadius(50)
                .frame(minWidth: screenWidth*0.4, maxWidth: screenWidth*0.65, minHeight: screenHeight*0.2, maxHeight: screenHeight*0.2)
                
                Spacer(minLength: 10)
                
                Button(action: {
                    pinDays()
                }) {
                    Image(systemName: "pin.fill")
                        .font(.headline)
                        .frame(minWidth: screenWidth*0.25, maxWidth: screenWidth*0.25, minHeight: screenHeight*0.2, maxHeight: screenHeight*0.2)
                        .minimumScaleFactor(0.4)
                }
                .cornerRadius(50)
                .frame(minWidth: screenWidth*0.25, maxWidth: screenWidth*0.25, minHeight: screenHeight*0.2, maxHeight: screenHeight*0.2)
                .alert(isPresented: $showAlert) {
                    Alert(title: alertMessage)
                }.fixedSize()
                
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: screenHeight/3.5)
        }.onAppear {
            futureDate = calculateDate(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
        }
    }
    
    // Function to pin the days
    func pinDays() {
        var days = (try? JSONDecoder().decode([DayInfo].self, from: pinnedDaysData)) ?? []
        let newDayInfo = DayInfo(days: daysToAdd, includeFirstDay: includeFirstDay)
        if days.contains(newDayInfo) {
            alertMessage = Text("Already registered.")
        } else {
            days.append(newDayInfo)
            if let encodedData = try? JSONEncoder().encode(days) {
                pinnedDaysData = encodedData
            }
            alertMessage = Text("Pinned.")
        }
        showAlert = true
    }
}

struct MainViewPreview: PreviewProvider {
    static var previews: some View {
        let localizationIds = ["en", "ja"]
        
        ForEach(localizationIds, id: \.self) { id in
            MainView()
                .previewDisplayName("Localized - \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}
