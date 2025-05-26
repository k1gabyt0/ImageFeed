import WebKit

protocol SessionInfoStorage {
    func resetSessionInfo()
}

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private var loginInfoItems : [SessionInfoStorage] = []
    
    private init() {}

    func register(sessionInfoStorage item: SessionInfoStorage) {
        loginInfoItems.append(item)
    }
    
    func logout() {
        for item in loginInfoItems {
            item.resetSessionInfo()
        }
        cleanCookies()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
        }
    }
}
