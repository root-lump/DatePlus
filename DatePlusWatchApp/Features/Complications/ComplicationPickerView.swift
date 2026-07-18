import DatePlusCore
import SwiftUI

struct ComplicationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @EnvironmentObject private var model: AppModel

    let dayInfo: DayInfo

    private var localizer: AppLocalizer { AppLocalizer(locale: locale) }

    var body: some View {
        NavigationStack {
            VStack {
                Text(localizer.text(.addWatchFace))
                    .font(.title3)
                    .fontWeight(.black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding()

                Text(localizer.daysDescription(
                    days: dayInfo.days,
                    includeFirstDay: dayInfo.includeFirstDay
                ))
                .font(.title2)
                .fontWeight(.black)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

                Text(localizer.text(.selectWidgetNumber))
                    .font(.caption)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding()

                Spacer()

                if #unavailable(watchOS 10) {
                    HStack {
                        slotButtons
                    }
                }
            }
            .toolbar {
                if #available(watchOS 10, *) {
                    ToolbarItemGroup(placement: .bottomBar) {
                        slotButtons
                    }
                }
            }
            .datePlusComplicationBackground()
        }
    }

    private var slotButtons: some View {
        ForEach(ComplicationSlot.allCases, id: \.rawValue) { slot in
            Button(String(slot.rawValue)) {
                model.register(dayInfo, in: slot)
                dismiss()
            }
            .controlSize(.large)
            .background(.orange, in: Capsule())
        }
    }
}

private extension View {
    @ViewBuilder
    func datePlusComplicationBackground() -> some View {
        if #available(watchOS 10, *) {
            containerBackground(.orange.gradient, for: .navigation)
        } else {
            background(.orange.gradient)
        }
    }
}
