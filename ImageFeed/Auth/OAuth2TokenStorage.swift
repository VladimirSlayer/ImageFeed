import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    // MARK: - Properties
    private let key = "BearerToken"

    // MARK: - Authorization token
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: key)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: key)
            } else {
                KeychainWrapper.standard.removeObject(forKey: key)
            }
        }
    }
    func clearToken() {
        KeychainWrapper.standard.removeObject(forKey: key)
    }
}
