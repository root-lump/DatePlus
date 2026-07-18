import Foundation

public enum DateCalculator {
    public static func calculate(
        from date: Date = Date(),
        daysToAdd: Int,
        includeFirstDay: Bool,
        calendar: Calendar = .current
    ) -> Date {
        let offset = daysToAdd - (includeFirstDay ? 1 : 0)
        return calendar.date(byAdding: .day, value: offset, to: date) ?? date
    }
}
