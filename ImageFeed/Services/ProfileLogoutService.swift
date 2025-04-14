import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    let tokenStorage = OAuth2TokenStorage()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        tokenStorage.clearToken()
        ProfileService.shared.clearProfile()
        ProfileImageService.shared.clearAvatarURL()
        ImagesListService.shared.clearPhotos()
        switchToSplashScreen()
    }
    
    private func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let splashVC = SplashViewController()
        
        UIView.transition(with: window, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                window.rootViewController = splashVC
            }, completion: nil)
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

