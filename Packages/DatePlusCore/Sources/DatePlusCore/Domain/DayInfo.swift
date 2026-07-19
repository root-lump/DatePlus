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

    // Calculation inputs define a unique pinned day. The UUID exists only for
    // persistence and SwiftUI list identity, so it must not affect deduplication.
    public static func == (lhs: DayInfo, rhs: DayInfo) -> Bool {
        lhs.days == rhs.days && lhs.includeFirstDay == rhs.includeFirstDay
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(days)
        hasher.combine(includeFirstDay)
    }
}
