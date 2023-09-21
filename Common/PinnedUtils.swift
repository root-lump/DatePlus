import Foundation
import SwiftUI

func getAllPinnedDays() -> [DayInfo] {
    @AppStorage("pinnedDays") var pinnedDaysData: Data = Data()
    let pinnedDays = (try? JSONDecoder().decode([DayInfo].self, from: pinnedDaysData)) ?? []
    return pinnedDays
}

func setAllPinnedDays(pinnedDays: [DayInfo]) {
    @AppStorage("pinnedDays") var pinnedDaysData: Data = Data()
    if let encodedData = try? JSONEncoder().encode(pinnedDays) {
        pinnedDaysData = encodedData
    }
}

func registerPinnedDay(dayInfo: DayInfo) -> [DayInfo] {
    return registerPinnedDay(daysToAdd: dayInfo.days, includeFirstDay: dayInfo.includeFirstDay)
}

func registerPinnedDay(daysToAdd: Int, includeFirstDay: Bool) -> [DayInfo] {
    var pinnedDays = getAllPinnedDays()
    let dayInfo = DayInfo(days: daysToAdd, includeFirstDay: includeFirstDay)
    pinnedDays.append(dayInfo)
    setAllPinnedDays(pinnedDays: pinnedDays)
    return pinnedDays
}

func existPinnedDay(dayInfo: DayInfo) -> Bool {
    return existPinnedDay(daysToAdd: dayInfo.days, includeFirstDay: dayInfo.includeFirstDay)
}

func existPinnedDay(daysToAdd: Int, includeFirstDay: Bool) -> Bool{
    let pinnedDays = getAllPinnedDays()
    return pinnedDays.contains(where: {$0.days == daysToAdd && $0.includeFirstDay == includeFirstDay})
}

func removePinnedDay(dayInfo: DayInfo) -> [DayInfo] {
    return removePinnedDay(daysToAdd: dayInfo.days, includeFirstDay: dayInfo.includeFirstDay)
}

func removePinnedDay(daysToAdd: Int, includeFirstDay: Bool) -> [DayInfo] {
    var pinnedDays = getAllPinnedDays()
    print(String(daysToAdd) + "," + String(includeFirstDay))
    pinnedDays.removeAll(where: {$0.days == daysToAdd && $0.includeFirstDay == includeFirstDay})
    setAllPinnedDays(pinnedDays: pinnedDays)
    return pinnedDays
}
