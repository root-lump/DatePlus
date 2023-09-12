import Foundation
import SwiftUI

func formatDate(date: Date, localeCode: String) -> String {
    let formatter = DateFormatter()
    switch localeCode {
    case "ja":
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日 (E)"
        break;
    case "en":
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "E, MMMM d, yyyy"
        break;
    default:
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "E, MMMM d, yyyy"
        break;
    }

    return formatter.string(from: date)
}

extension Int {
    var ordinal: String {
        switch self {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default:
            return "\(self)th"
        }
    }
}

extension Int {
    var localizedString: String {
        if (String(localized: "Locale Code") == "en") {
            return self.ordinal
        } else {
            return "\(self)"
        }
    }
}

/**
 Calculate the date by adding the number of days to a specific date
 */
func calculateDate(date: Date = Date(), daysToAdd: Int, includeFirstDay: Bool) -> Date {
    let addNum = daysToAdd - (includeFirstDay ? 1 : 0)
    return Calendar.current.date(byAdding: .day, value: addNum, to: date) ?? date
}
