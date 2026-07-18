import Foundation

public struct AppLocalizer: Sendable {
    public let locale: Locale

    public init(locale: Locale = .current) {
        self.locale = locale
    }

    public func text(_ key: AppStringKey) -> String {
        let resource = LocalizedStringResource(
            String.LocalizationValue(key.rawValue),
            table: "Localizable",
            locale: locale,
            bundle: .atURL(Bundle.module.bundleURL)
        )
        return String(localized: resource)
    }

    public func daysDescription(days: Int, includeFirstDay: Bool) -> String {
        let value = DateTextFormatter(locale: locale).ordinal(days)
        let unit = text(includeFirstDay ? .day : .daysLater)
        return isJapanese ? "\(value)\(unit)" : "\(value) \(unit)"
    }

    public func cornerDaysDescription(days: Int, includeFirstDay: Bool) -> String {
        let unit = text(includeFirstDay ? .widgetDay : .widgetDaysLater)
        return "(\(days)\(unit))"
    }

    private var isJapanese: Bool {
        locale.language.languageCode?.identifier == "ja"
    }
}
