@testable import ImageFeed
import Foundation

final class ImagesListViewSpy: ImagesListViewControllerProtocol {
    var updateTableAnimatedCalled = false
    var reloadRowCalled = false
    var showLikeErrorCalled = false

    func updateTableAnimated(oldCount: Int, newCount: Int) {
        updateTableAnimatedCalled = true
    }

    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
    }

    func showLikeError(message: String) {
        showLikeErrorCalled = true
    }
}
