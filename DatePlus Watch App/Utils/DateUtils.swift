import Foundation
import SwiftUI

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    switch String(localized: "Locale Code") {
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

/**
 Calculate the date by adding the number of days to a specific date
 */
func calculateDate(date: Date = Date(), daysToAdd: Int, includeFirstDay: Bool) -> Date {
    let addNum = daysToAdd - (includeFirstDay ? 1 : 0)
    return Calendar.current.date(byAdding: .day, value: addNum, to: date) ?? date
}
