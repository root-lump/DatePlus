import DatePlusCore
import SwiftUI

@available(watchOS 10, *)
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

                ForEach(ComplicationSlot.allCases, id: \.rawValue) { slot in
                    let registered = model.complication(for: slot)
                    let description = localizer.daysDescription(
                        days: registered.days,
                        includeFirstDay: registered.includeFirstDay
                    )
                    Text("\(slot.widgetKind) \(description)")
                        .font(.caption2)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }

                Spacer()

            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    slotButtons
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
    @available(watchOS 10, *)
    @ViewBuilder
    func datePlusComplicationBackground() -> some View {
        containerBackground(.orange.gradient, for: .navigation)
    }
}
