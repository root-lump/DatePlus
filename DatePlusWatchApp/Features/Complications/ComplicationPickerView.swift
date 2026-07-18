import DatePlusCore
import SwiftUI

struct ComplicationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @EnvironmentObject private var model: AppModel

    let dayInfo: DayInfo

    private var localizer: AppLocalizer { AppLocalizer(locale: locale) }

    var body: some View {
        List(ComplicationSlot.allCases, id: \.rawValue) { slot in
            Button {
                model.register(dayInfo, in: slot)
                dismiss()
            } label: {
                VStack(alignment: .leading) {
                    Text("Widget \(slot.rawValue)")
                    Text(localizer.daysDescription(
                        days: model.complication(for: slot).days,
                        includeFirstDay: model.complication(for: slot).includeFirstDay
                    ))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(localizer.text(.selectWidgetNumber))
    }
}
