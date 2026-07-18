import Foundation

public struct DateTextFormatter: Sendable {
    public let locale: Locale

    public init(locale: Locale) {
        self.locale = locale
    }

    public func fullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = isJapanese ? "yyyy年M月d日 (E)" : "E, MMMM d, yyyy"
        return formatter.string(from: date)
    }

    public func compactDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = isJapanese ? "M月d日" : "MMM d"
        return formatter.string(from: date)
    }

    public func ordinal(_ number: Int) -> String {
        guard !isJapanese else {
            return String(number)
        }

        let remainder100 = abs(number) % 100
        let suffix: String
        if 11...13 ~= remainder100 {
            suffix = "th"
        } else {
            switch abs(number) % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        return "\(number)\(suffix)"
    }

    private var isJapanese: Bool {
        locale.language.languageCode?.identifier == "ja"
    }
}
