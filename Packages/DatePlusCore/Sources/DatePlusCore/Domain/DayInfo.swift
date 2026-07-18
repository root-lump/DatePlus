import Foundation

public struct DayInfo: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let days: Int
    public let includeFirstDay: Bool

    public init(
        id: UUID = UUID(),
        days: Int,
        includeFirstDay: Bool
    ) {
        self.id = id
        self.days = days
        self.includeFirstDay = includeFirstDay
    }

    public static func == (lhs: DayInfo, rhs: DayInfo) -> Bool {
        lhs.days == rhs.days && lhs.includeFirstDay == rhs.includeFirstDay
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(days)
        hasher.combine(includeFirstDay)
    }
}
