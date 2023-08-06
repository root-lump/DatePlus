import Foundation

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    formatter.dateFormat = "yyyy年M月d日 (E)"
    return formatter.string(from: date)
}

/**
 Calculate the date by adding the number of days to a specific date
 */
func calculateDate(date: Date = Date(), daysToAdd: Int, includeFirstDay: Bool) -> Date {
    let addNum = daysToAdd - (includeFirstDay ? 1 : 0)
    return Calendar.current.date(byAdding: .day, value: addNum, to: date) ?? date
}
