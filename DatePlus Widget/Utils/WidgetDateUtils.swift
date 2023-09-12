import Foundation

func getDaysToAddStrings(daysToAdd: Int, includeFirstDay: Bool, localizationManager: LocalizationManager) -> String {
    if #available(watchOSApplicationExtension 10.0, *) {
        var daysToAddString = ""
        if (includeFirstDay) {
            daysToAddString = "\(getLocalizedDay(days: daysToAdd, localizationManager: localizationManager))"
        } else {
            daysToAddString = "\(daysToAdd)"
        }
        
        if (includeFirstDay){
            return daysToAddString + localizationManager.localize(.day)
        }else{
            if (localizationManager.localize(.localeCode) == "en" && daysToAdd == 1) {
                return daysToAddString + "day later"
            } else {
                return daysToAddString + localizationManager.localize(.daysLater)
            }
        }
    }else{
        return " (\(daysToAdd)" + (includeFirstDay ? localizationManager.localize(.widgetDay) : localizationManager.localize(.widgetDaysLater)) + ")"
    }
    
}

func formatWidgetDate(date: Date, localizationManager: LocalizationManager) -> String {
    let formatter = DateFormatter()
    switch localizationManager.localize(.localeCode) {
    case "ja":
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        break;
    case "en":
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d"
        break;
    default:
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d"
        break;
    }
    
    return formatter.string(from: date);
}
