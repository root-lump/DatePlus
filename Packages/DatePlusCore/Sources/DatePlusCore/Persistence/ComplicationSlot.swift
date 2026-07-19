public enum ComplicationSlot: Int, CaseIterable, Sendable {
    case one = 1
    case two = 2
    case three = 3

    public var widgetKind: String {
        // WidgetKit persists this kind in installed watch-face configurations,
        // so the legacy identifiers must remain stable.
        "[\(rawValue)]"
    }

    var index: Int {
        rawValue - 1
    }

    public init?(widgetKind: String) {
        guard let slot = Self.allCases.first(where: { $0.widgetKind == widgetKind }) else {
            return nil
        }
        self = slot
    }
}
