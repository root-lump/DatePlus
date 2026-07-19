import DatePlusCore
import SwiftUI
import WidgetKit

private let pinnedDaysURL = URL(string: "dateplus://deeplink?from=widget")

// Keep concrete Widget types here. Replacing these wrappers with parameterized
// instances broke WidgetBundle compilation for the watchOS extension.
struct WidgetOne: Widget {
    var body: some WidgetConfiguration {
        configuration(for: .one)
    }
}

struct WidgetTwo: Widget {
    var body: some WidgetConfiguration {
        configuration(for: .two)
    }
}

struct WidgetThree: Widget {
    var body: some WidgetConfiguration {
        configuration(for: .three)
    }
}

@main
struct DatePlusWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        WidgetOne()
        // The extra slots use APIs unavailable to the watchOS 9 extension path.
        if #available(watchOSApplicationExtension 10, *) {
            WidgetTwo()
            WidgetThree()
        }
    }
}

private func configuration(for slot: ComplicationSlot) -> some WidgetConfiguration {
    let language = Bundle.main.preferredLocalizations.first
    let locale = language.map { Locale(identifier: $0) } ?? .current
    let localizer = AppLocalizer(locale: locale)
    // Widget descriptors are archived before providers run, so their metadata
    // must not read App Group data. The name must also stay an explicit String:
    // the Text/LocalizedStringKey overloads of configurationDisplayName trap at
    // descriptor time ("Formatted text ... is not supported") and take every
    // complication down with them.
    let displayName: String = "\(slot.widgetKind) DatePlus"

    return StaticConfiguration(
        kind: slot.widgetKind,
        provider: DateCounterProvider(slot: slot)
    ) { entry in
        DatePlusWidgetView(entry: entry)
            .widgetURL(pinnedDaysURL)
    }
    .configurationDisplayName(
        displayName
    )
    .description(localizer.text(.widgetDescription))
    .supportedFamilies(supportedFamilies(for: slot))
}

private func supportedFamilies(for slot: ComplicationSlot) -> [WidgetFamily] {
    // The circular family is a slot-independent app launcher (icon only), so
    // offering it from a single kind avoids three identical gallery entries.
    var families: [WidgetFamily] = [
        .accessoryCorner,
        .accessoryRectangular,
        .accessoryInline,
    ]
    if slot == .one {
        families.insert(.accessoryCircular, at: 1)
    }
    return families
}
