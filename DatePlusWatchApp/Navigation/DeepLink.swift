import Foundation

extension URL {
    var opensPinnedDays: Bool {
        scheme == "dateplus"
            && host == "deeplink"
            && URLComponents(url: self, resolvingAgainstBaseURL: false)?
                .queryItems?
                .contains(where: { $0.name == "from" && $0.value == "widget" }) == true
    }
}
