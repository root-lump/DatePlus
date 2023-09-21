import Foundation

struct DayInfo: Codable, Hashable, Identifiable {
    let id: UUID
    let days: Int
    let includeFirstDay: Bool
    
    init(days: Int, includeFirstDay: Bool) {
        self.id = UUID()
        self.days = days
        self.includeFirstDay = includeFirstDay
    }
    
    static func == (lhs: DayInfo, rhs: DayInfo) -> Bool {
        return lhs.days == rhs.days && lhs.includeFirstDay == rhs.includeFirstDay
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
