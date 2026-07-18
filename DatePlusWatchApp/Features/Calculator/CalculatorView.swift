import DatePlusCore
import SwiftUI
import WatchKit

struct CalculatorView: View {
    @Environment(\.locale) private var locale
    @EnvironmentObject private var model: AppModel
    @AppStorage(StorageConfiguration.daysToAddKey) private var daysToAdd = 1
    @AppStorage(StorageConfiguration.includeFirstDayKey) private var includeFirstDay = false
    @State private var futureDate = Date()

    let showsInlinePinButton: Bool

    init(showsInlinePinButton: Bool = true) {
        self.showsInlinePinButton = showsInlinePinButton
    }

    private var localizer: AppLocalizer { AppLocalizer(locale: locale) }
    private var dateFormatter: DateTextFormatter { DateTextFormatter(locale: locale) }

    var body: some View {
        let screen = WKInterfaceDevice.current().screenBounds

        VStack {
            Spacer()

            HStack {
                Spacer()

                Picker("", selection: $daysToAdd) {
                    ForEach(1..<151, id: \.self) { value in
                        Text(includeFirstDay ? dateFormatter.ordinal(value) : String(value))
                            .font(.largeTitle)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .pickerStyle(.wheel)
                .frame(width: screen.width / 1.8)

                Spacer()

                Text(dayUnit)
                    .font(.title)
                    .minimumScaleFactor(0.4)
                    .lineLimit(2)

                Spacer()
            }
            .frame(height: screen.height * 0.225)
            .padding(.vertical, 5)

            Text(dateFormatter.fullDate(futureDate))
                .frame(height: screen.height * 0.175)
                .font(.title3)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            if showsInlinePinButton {
                HStack {
                    Spacer()
                    fromTodayButton(screen: screen)
                    Spacer(minLength: 10)
                    pinButton(screen: screen)
                    Spacer()
                }
                .padding(.horizontal)
                .frame(height: screen.height / 3.5)
            } else {
                fromTodayButton(screen: screen)
            }
        }
        .toolbar {
            if !showsInlinePinButton {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: togglePinned) {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(isPinned ? Color.red : Color.white)
                    }
                    .background(isPinned ? Color.white : Color.clear, in: Capsule())
                    .accessibilityLabel(localizer.text(.pinnedItem))
                }
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

    private func fromTodayButton(screen: CGRect) -> some View {
        Button {
            includeFirstDay.toggle()
            updateFutureDate()
        } label: {
            Text(localizer.text(.fromToday))
                .font(.headline)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .frame(
                    minWidth: screen.width * 0.4,
                    maxWidth: screen.width * 0.5,
                    minHeight: screen.height * 0.2,
                    maxHeight: screen.height * 0.2
                )
                .foregroundStyle(includeFirstDay ? Color.black : Color.white)
        }
        .background(includeFirstDay ? Color.white : Color.clear)
        .clipShape(Capsule())
        .frame(
            minWidth: screen.width * 0.4,
            maxWidth: screen.width * 0.65,
            minHeight: screen.height * 0.2,
            maxHeight: screen.height * 0.2
        )
    }

    private func pinButton(screen: CGRect) -> some View {
        Button(action: togglePinned) {
            Image(systemName: "pin.fill")
                .font(.headline)
                .foregroundStyle(isPinned ? Color.red : Color.white)
                .frame(
                    minWidth: screen.width * 0.25,
                    maxWidth: screen.width * 0.25,
                    minHeight: screen.height * 0.2,
                    maxHeight: screen.height * 0.2
                )
        }
        .clipShape(Capsule())
        .frame(
            minWidth: screen.width * 0.25,
            maxWidth: screen.width * 0.25,
            minHeight: screen.height * 0.2,
            maxHeight: screen.height * 0.2
        )
        .accessibilityLabel(localizer.text(.pinnedItem))
    }

    private func togglePinned() {
        model.togglePinned(days: daysToAdd, includeFirstDay: includeFirstDay)
    }

    private func updateFutureDate() {
        futureDate = DateCalculator.calculate(
            daysToAdd: daysToAdd,
            includeFirstDay: includeFirstDay
        )
    }
}
