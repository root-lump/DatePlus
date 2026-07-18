import DatePlusCore
import SwiftUI

struct PinnedDaysView: View {
    @Environment(\.locale) private var locale
    @EnvironmentObject private var model: AppModel
    @State private var complicationDay: DayInfo?
    @State private var deletingDay: DayInfo?

    private var localizer: AppLocalizer { AppLocalizer(locale: locale) }
    private var formatter: DateTextFormatter { DateTextFormatter(locale: locale) }

    var body: some View {
        Group {
            if model.pinnedDays.isEmpty {
                VStack(spacing: 8) {
                    Label(localizer.text(.pinnedNothing), systemImage: "pin.slash")
                        .font(.headline)
                    Text(localizer.text(.pinnedTip))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                List(model.pinnedDays) { dayInfo in
                    VStack(alignment: .leading) {
                        Text(localizer.daysDescription(
                            days: dayInfo.days,
                            includeFirstDay: dayInfo.includeFirstDay
                        ))
                        .foregroundStyle(.secondary)

                        Spacer()

                        Text(formatter.fullDate(DateCalculator.calculate(
                            daysToAdd: dayInfo.days,
                            includeFirstDay: dayInfo.includeFirstDay
                        )))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    }
                    .padding(8)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deletingDay = dayInfo
                        } label: {
                            Label(localizer.text(.delete), systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            complicationDay = dayInfo
                        } label: {
                            Label(
                                localizer.text(.addToComplications),
                                systemImage: "watchface.applewatch.case"
                            )
                        }
                        .tint(.orange)
                    }
                }
            }
        }
        .navigationTitle(localizer.text(.pinList))
        .sheet(item: $complicationDay) { dayInfo in
            ComplicationPickerView(dayInfo: dayInfo)
        }
        .confirmationDialog(
            localizer.text(.confirmDelete),
            isPresented: Binding(
                get: { deletingDay != nil },
                set: { if !$0 { deletingDay = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(localizer.text(.delete), role: .destructive) {
                if let deletingDay { model.removePinned(deletingDay) }
                deletingDay = nil
            }
            Button(localizer.text(.cancel), role: .cancel) {
                deletingDay = nil
            }
        }
    }
}
