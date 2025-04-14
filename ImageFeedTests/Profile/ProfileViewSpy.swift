@testable import ImageFeed
import Foundation

final class ProfileViewSpy: ProfileViewControllerProtocol {
    var updateProfileCalled = false
    var updateAvatarCalled = false
    
    func updateProfileDetails(profile: Profile) {
        updateProfileCalled = true
    }
    
    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
    }
}
