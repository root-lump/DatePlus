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

// The main view of the app
struct MainView: View {
    // App storage properties to store user preferences
    @AppStorage("daysToAdd") private var daysToAdd = 1
    @State private var futureDate = Date()
    @AppStorage("pinnedDays") private var pinnedDaysData: Data = Data()
    @AppStorage("includeFirstDay") private var includeFirstDay = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        // Binding to update the future date whenever the number of days to add changes
        let daysBinding = Binding<Int>(
            get: { self.daysToAdd },
            set: {
                self.daysToAdd = $0
                self.futureDate = calculateDate(daysToAdd: self.daysToAdd, includeFirstDay: self.includeFirstDay)
            }
        )
        
        // The main view layout
        VStack {
            HStack {
                Spacer()
                Picker("", selection: daysBinding) {
                    ForEach(1 ..< 151, id: \.self) { num in     // Repeat by id
                        Text("\(num)").font(.largeTitle)                                    }
                    
                }
                .labelsHidden()
                .pickerStyle(WheelPickerStyle())
                Text(includeFirstDay ? "日目" : "日後").font(.title)
                Spacer()
            }
            .padding(.vertical, 5) // Add vertical padding
            
            Text(" \(formatDate(futureDate))")
                .font(.title3)
                .padding(.vertical, 5)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            HStack {
                Spacer()
                Button(action: {
                    includeFirstDay.toggle()
                    futureDate = calculateDate(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
                }) {
                    Text("本日起算")
                        .font(.headline)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(5) // Adjust padding
                        .foregroundColor(includeFirstDay ? .black : .white) // Set text color
                }
                .background(includeFirstDay ? Color.white : Color.clear)
                .cornerRadius(50)
                .frame(minWidth: 0, maxWidth: 150)
                
                Spacer(minLength: 10)
                
                Button(action: {
                    pinDays()
                }) {
                    Image(systemName: "pin.fill")
                        .font(.title3)
                        .padding(5)
                }.clipShape(Circle()) // Clip to circle shape
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertMessage))
                    }.fixedSize()
                
                Spacer()
            }.padding(.horizontal, 5)
        }.onAppear {
            futureDate = calculateDate(daysToAdd: daysToAdd, includeFirstDay: includeFirstDay)
        }
    }
    
    // Function to pin the days
    func pinDays() {
        var days = (try? JSONDecoder().decode([DayInfo].self, from: pinnedDaysData)) ?? []
        let newDayInfo = DayInfo(days: daysToAdd, includeFirstDay: includeFirstDay)
        if days.contains(newDayInfo) {
            alertMessage = "既に登録されています。"
        } else {
            days.append(newDayInfo)
            if let encodedData = try? JSONEncoder().encode(days) {
                pinnedDaysData = encodedData
            }
            alertMessage = "ピン留めしました。"
        }
        showAlert = true
    }
}

struct MainViewPreview: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
