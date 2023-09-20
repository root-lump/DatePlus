import SwiftUI

func getDaysToAddText(localizationManager: LocalizationManager, dayInfo: DayInfo) -> Text {
    // Change the display by includeFirstDay.
    if (dayInfo.includeFirstDay) {
        return Text("\(getLocalizedDay(days: dayInfo.days, localizationManager: localizationManager)) \(Text(localizationManager.localize(.day)))")
    } else {
        if (localizationManager.localize(.localeCode) == "en" && dayInfo.days == 1) {
            return Text("\(dayInfo.days) day later")
        } else {
            return Text("\(dayInfo.days) \(localizationManager.localize(.daysLater))")
        }
    }
}

