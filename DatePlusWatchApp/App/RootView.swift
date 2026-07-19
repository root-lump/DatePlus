import DatePlusCore
import Foundation
import SwiftUI

struct RootView: View {
    @StateObject private var model: AppModel
    private let locale: Locale

    init(locale: Locale? = nil, model: AppModel? = nil) {
        _model = StateObject(wrappedValue: model ?? AppModel())
        // Follow the app bundle localization so package-backed strings use the
        // language selected for DatePlus instead of an unrelated system locale.
        let language = Bundle.main.preferredLocalizations.first
        self.locale = locale ?? language.map { Locale(identifier: $0) } ?? .current
    }

    var body: some View {
        Group {
            if #available(watchOS 10, *) {
                ModernNavigationView()
            } else {
                LegacyNavigationView()
            }
        }
        .environmentObject(model)
        .environment(\.locale, locale)
    }
}

#Preview("English") {
    RootView(
        locale: Locale(identifier: "en"),
        model: makePreviewModel()
    )
}

#Preview("Japanese") {
    RootView(
        locale: Locale(identifier: "ja"),
        model: makePreviewModel()
    )
}

@MainActor
private func makePreviewModel() -> AppModel {
    // Isolated stores and a no-op reloader keep canvas interactions from
    // mutating simulator app data or asking WidgetKit to refresh timelines.
    let model = AppModel(
        standardStore: PreviewKeyValueStore(),
        complicationStore: ComplicationStore(store: PreviewKeyValueStore()),
        reloadTimelines: { _ in },
        reloadAllTimelines: { }
    )
    _ = model.pin(days: 7, includeFirstDay: false)
    return model
}

private final class PreviewKeyValueStore: KeyValueStore, @unchecked Sendable {
    private let lock = NSLock()
    private var dataValues: [String: Data] = [:]
    private var integerValues: [String: Int] = [:]
    private var booleanValues: [String: Bool] = [:]

    func data(forKey key: String) -> Data? {
        lock.withLock { dataValues[key] }
    }

    func integer(forKey key: String) -> Int? {
        lock.withLock { integerValues[key] }
    }

    func boolean(forKey key: String) -> Bool? {
        lock.withLock { booleanValues[key] }
    }

    func write(_ data: Data, forKey key: String) {
        lock.withLock { dataValues[key] = data }
    }

    func write(_ value: Int, forKey key: String) {
        lock.withLock { integerValues[key] = value }
    }

    func write(_ value: Bool, forKey key: String) {
        lock.withLock { booleanValues[key] = value }
    }
}
