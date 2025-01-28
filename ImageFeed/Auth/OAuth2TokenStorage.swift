import Foundation

final class OAuth2TokenStorage {
    // MARK: - Properties
    private let key = "BearerToken"
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Authorization token
    var token: String? {
        get {
            return userDefaults.string(forKey: key)
        }
        set {
            userDefaults.set(newValue, forKey: key)
        }
    }
}
