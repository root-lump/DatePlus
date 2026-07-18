import DatePlusCore
import SwiftUI

struct PinnedDaysView: View {
    @Environment(\.locale) private var locale
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var model: AppModel
    @State private var complicationDay: DayInfo?
    @State private var deletingDay: DayInfo?
    @State private var legacyAction: LegacyPinnedAction?
    @State private var nowDate = Date()

    private var localizer: AppLocalizer { AppLocalizer(locale: locale) }
    private var formatter: DateTextFormatter { DateTextFormatter(locale: locale) }

    var body: some View {
        Group {
            if #available(watchOS 10, *) {
                listContent
                    .sheet(item: $complicationDay) { dayInfo in
                        ComplicationPickerView(dayInfo: dayInfo)
                    }
                    .sheet(item: $deletingDay) { dayInfo in
                        DeletePinnedDayView(dayInfo: dayInfo)
                    }
            } else {
                listContent
                    .alert(item: $legacyAction, content: legacyAlert)
            }
        }
        .navigationTitle(localizer.text(.pinList))
        .onAppear { nowDate = Date() }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                nowDate = Date()
            }
        }
    }

    @ViewBuilder
    private var listContent: some View {
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
                        from: nowDate,
                        daysToAdd: dayInfo.days,
                        includeFirstDay: dayInfo.includeFirstDay
                    )))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                }
                .padding(8)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        if #available(watchOS 10, *) {
                            deletingDay = dayInfo
                        } else {
                            legacyAction = LegacyPinnedAction(kind: .delete(dayInfo))
                        }
                    } label: {
                        Label(localizer.text(.delete), systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        if #available(watchOS 10, *) {
                            complicationDay = dayInfo
                        } else {
                            legacyAction = LegacyPinnedAction(kind: .complication(dayInfo))
                        }
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

    private func legacyAlert(for action: LegacyPinnedAction) -> Alert {
        switch action.kind {
        case let .delete(dayInfo):
            return Alert(
                title: Text(localizer.text(.confirmDelete)),
                primaryButton: .destructive(Text(localizer.text(.delete))) {
                    model.removePinned(dayInfo)
                },
                secondaryButton: .cancel(Text(localizer.text(.cancel)))
            )
        case let .complication(dayInfo):
            return Alert(
                title: Text(localizer.text(.confirmComplication)),
                primaryButton: .cancel(Text(localizer.text(.cancel))),
                secondaryButton: .default(Text(localizer.text(.update))) {
                    model.register(dayInfo, in: .one)
                }
            )
        }
    }
}

private struct LegacyPinnedAction: Identifiable {
    enum Kind {
        case delete(DayInfo)
        case complication(DayInfo)
    }

    let id = UUID()
    let kind: Kind
}

@available(watchOS 10, *)
private struct DeletePinnedDayView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @EnvironmentObject private var model: AppModel

    let dayInfo: DayInfo

    private var localizer: AppLocalizer { AppLocalizer(locale: locale) }

    var body: some View {
        NavigationStack {
            VStack {
                Text(localizer.text(.confirmDelete))
                    .font(.title3)
                    .fontWeight(.black)
                    .minimumScaleFactor(0.8)
                    .lineLimit(3)
                    .padding()

                Text(localizer.daysDescription(
                    days: dayInfo.days,
                    includeFirstDay: dayInfo.includeFirstDay
                ))
                .font(.title2)
                .fontWeight(.black)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

                Spacer()
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        model.removePinned(dayInfo)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text(localizer.text(.delete))
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .padding()
                    }
                    .controlSize(.large)
                    .background(.red, in: Capsule())
                }
            }
            .containerBackground(.red.gradient, for: .navigation)
        }
    }
}
