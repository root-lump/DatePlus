import Foundation

func registerComplication(number: Int, dayInfo: DayInfo) {
    var dayInfos = loadComplicationDayInfo()
    if dayInfos.count < 3 {
        for _ in 1...3 {
            dayInfos.append(DayInfo(days: 1, includeFirstDay: true))
        }
    }
    dayInfos[number - 1] = dayInfo
    saveComplicationDayInfo(dayInfos: dayInfos)
}

func saveComplicationDayInfo(dayInfos: [DayInfo]) {
    let userDefaults = UserDefaults(suiteName: "group.net.root-lump.date-plus")
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(dayInfos) {
        userDefaults?.set(encoded, forKey: "dayInfos")
        userDefaults?.synchronize()
    }
}

func loadComplicationDayInfo() -> [DayInfo] {
    let userDefaults = UserDefaults(suiteName: "group.net.root-lump.date-plus")
    let decoder = JSONDecoder()
    if let data = userDefaults?.data(forKey: "dayInfos"),
       let dayInfos = try? decoder.decode([DayInfo].self, from: data) {
        return dayInfos
    }
    return []
}

