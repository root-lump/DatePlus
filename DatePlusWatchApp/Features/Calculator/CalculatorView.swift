import DatePlusCore
import SwiftUI
import WatchKit

struct CalculatorView: View {
    @Environment(\.locale) private var locale
    @EnvironmentObject private var model: AppModel
    @AppStorage(StorageConfiguration.daysToAddKey) private var daysToAdd = 1
    @AppStorage(StorageConfiguration.includeFirstDayKey) private var includeFirstDay = false
    @State private var futureDate = Date()

    private var localizer: AppLocalizer { AppLocalizer(locale: locale) }
    private var dateFormatter: DateTextFormatter { DateTextFormatter(locale: locale) }

    var body: some View {
        let screen = WKInterfaceDevice.current().screenBounds

        VStack(spacing: 6) {
            HStack {
                Picker("", selection: $daysToAdd) {
                    ForEach(1..<151, id: \.self) { value in
                        Text(includeFirstDay ? dateFormatter.ordinal(value) : String(value))
                            .tag(value)
                    }
                }
                .labelsHidden()
                .pickerStyle(.wheel)
                .frame(width: screen.width / 1.8)

                Text(dayUnit)
                    .font(.title3)
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
            }
            .frame(height: screen.height * 0.28)

            Text(dateFormatter.fullDate(futureDate))
                .font(.footnote)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            HStack {
                Button(localizer.text(.fromToday)) {
                    includeFirstDay.toggle()
                    updateFutureDate()
                }
                .buttonStyle(.bordered)
                .tint(includeFirstDay ? .white : .gray)

                Button {
                    model.togglePinned(days: daysToAdd, includeFirstDay: includeFirstDay)
                } label: {
                    Image(systemName: "pin.fill")
                        .foregroundStyle(isPinned ? Color.red : Color.white)
                }
                .accessibilityLabel(localizer.text(.pinnedItem))
            }
        }
        .onAppear(perform: updateFutureDate)
        .onChange(of: daysToAdd) { _ in updateFutureDate() }
        .onChange(of: includeFirstDay) { _ in updateFutureDate() }
    }

    private var isPinned: Bool {
        model.isPinned(days: daysToAdd, includeFirstDay: includeFirstDay)
    }

    private var dayUnit: String {
        if !includeFirstDay && locale.language.languageCode?.identifier == "en" && daysToAdd == 1 {
            return "day\nlater"
        }
        return localizer.text(includeFirstDay ? .day : .daysLater)
    }

    private func updateFutureDate() {
        futureDate = DateCalculator.calculate(
            daysToAdd: daysToAdd,
            includeFirstDay: includeFirstDay
        )
    }
}
