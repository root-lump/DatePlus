import DatePlusCore
import SwiftUI

struct PinnedDaysView: View {
    @Environment(\.locale) private var locale
    @EnvironmentObject private var model: AppModel

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
                    NavigationLink {
                        ComplicationPickerView(dayInfo: dayInfo)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(localizer.daysDescription(
                                days: dayInfo.days,
                                includeFirstDay: dayInfo.includeFirstDay
                            ))
                            Text(formatter.compactDate(DateCalculator.calculate(
                                daysToAdd: dayInfo.days,
                                includeFirstDay: dayInfo.includeFirstDay
                            )))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            model.removePinned(dayInfo)
                        } label: {
                            Label(localizer.text(.delete), systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle(localizer.text(.pinList))
    }
}
