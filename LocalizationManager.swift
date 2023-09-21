import Foundation

enum LocalizedKey: String {
    case localeCode = "en"
    case day = "day"
    case daysLater = "days later"
    case fromToday = "From Today"
    case pinned = "Pinned."
    case alreadyRegistered = "Already registered."
    case pinnedNothing = "There are no days pinned."
    case pinnedTip = "💡Tip\nBy pressing the pin button on the main screen, you can display multiple dates together on this screen."
    case confirmDelete = "Are you sure you want to delete?"
    case delete = "Delete"
    case cancel = "Cancel"
    case confirmComplication = "Do you want to update the Complication?"
    case update = "Update"
    case widgetDay = "D"
    case widgetDaysLater = "D L"
    case addWatchFace = "Add to watchface"
    case selectWidgetNumber = "Select widget nunber."
    case pinList = "Pin list"
}

class LocalizationManager: ObservableObject {
    @Published var localeCode: String = "en"
    private var localizedStrings: [String: [LocalizedKey: String]] = [:]
    
    init(_ localeCode: String) {
        self.localeCode = localeCode
        loadEnglishStrings()
        loadJapaneseStrings()
    }
    
    private func loadEnglishStrings() {
        localizedStrings["en"] = englishLocalization
    }
    
    private func loadJapaneseStrings() {
        localizedStrings["ja"] = japaneseLocalization
    }
    
    func localize(_ key: LocalizedKey) -> String {
        return localizedStrings[localeCode]?[key] ?? key.rawValue
    }
    
    func setLocale(_ localeCode: String) {
        self.localeCode = localeCode
    }
}
