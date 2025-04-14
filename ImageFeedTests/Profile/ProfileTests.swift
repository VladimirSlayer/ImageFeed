@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        viewController.configure(presenter)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerLogoutTapCallsPresenter() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        // force view to load
        _ = viewController.view
        
        // when
        viewController.perform(Selector(("logoutTapped")))
        
        // then
        XCTAssertTrue(presenter.didTapLogoutCalled)
    }
}

