import DatePlusCore
import SwiftUI
import WatchKit

struct CalculatorView: View {
    @Environment(\.locale) private var locale
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var model: AppModel
    @State private var pinResultKey = AppStringKey.pinned
    @State private var showsPinResult = false

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

                Picker("", selection: $model.daysToAdd) {
                    ForEach(1..<151, id: \.self) { value in
                        Text(model.includeFirstDay ? dateFormatter.ordinal(value) : String(value))
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

            Text(dateFormatter.fullDate(model.futureDate))
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
            if #available(watchOS 10, *) {
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
        }
        .onAppear(perform: model.refreshFutureDate)
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                model.refreshFutureDate()
            }
        }
    }

    private var isPinned: Bool {
        model.isPinned(days: model.daysToAdd, includeFirstDay: model.includeFirstDay)
    }

    private var dayUnit: String {
        if !model.includeFirstDay
            && locale.language.languageCode?.identifier == "en"
            && model.daysToAdd == 1 {
            return localizer.text(.dayLaterMultiline)
        }
        return localizer.text(model.includeFirstDay ? .day : .daysLater)
    }

    private func fromTodayButton(screen: CGRect) -> some View {
        Button {
            model.toggleIncludeFirstDay()
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
                .foregroundStyle(model.includeFirstDay ? Color.black : Color.white)
        }
        .background(model.includeFirstDay ? Color.white : Color.clear)
        .clipShape(Capsule())
        .frame(
            minWidth: screen.width * 0.4,
            maxWidth: screen.width * 0.65,
            minHeight: screen.height * 0.2,
            maxHeight: screen.height * 0.2
        )
    }

    private func pinButton(screen: CGRect) -> some View {
        Button(action: pinForLegacyInterface) {
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
        .alert(localizer.text(pinResultKey), isPresented: $showsPinResult) {}
    }

    private func togglePinned() {
        model.togglePinned(days: model.daysToAdd, includeFirstDay: model.includeFirstDay)
    }

    private func pinForLegacyInterface() {
        pinResultKey = model.pin(
            days: model.daysToAdd,
            includeFirstDay: model.includeFirstDay
        )
            ? .pinned
            : .alreadyRegistered
        showsPinResult = true
    }
}
