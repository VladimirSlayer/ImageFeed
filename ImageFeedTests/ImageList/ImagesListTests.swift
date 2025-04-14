@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
            // given
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(
                withIdentifier: "ImagesListViewController"
            ) as! ImagesListViewController
            let presenter = ImagesListPresenterSpy()
            viewController.configure(presenter: presenter)

            // when
            _ = viewController.view
            
            // then
            XCTAssertTrue(presenter.viewDidLoadCalled)
        }

        func testPresenterReturnsCorrectPhoto() {
            // given
            let presenter = ImagesListPresenterSpy()
            
            // when
            let photo = presenter.photo(at: 0)

            // then
            XCTAssertEqual(photo.id, "id")
            XCTAssertEqual(presenter.photoCalledIndex, 0)
        }

        func testPresenterHandlesLikeTap() {
            // given
            let presenter = ImagesListPresenterSpy()
            
            // when
            presenter.didTapLike(at: 0)
            
            // then
            XCTAssertTrue(presenter.didTapLikeCalled)
            XCTAssertEqual(presenter.photoCalledIndex, 0)
        }

        func testPresenterHandlesWillDisplay() {
            // given
            let presenter = ImagesListPresenterSpy()

            // when
            presenter.willDisplayCell(at: 0)

            // then
            XCTAssertTrue(presenter.willDisplayCellCalled)
            XCTAssertEqual(presenter.photoCalledIndex, 0)
        }

        func testViewCallsUIUpdateMethods() {
            // given
            let view = ImagesListViewSpy()
            
            // when
            view.updateTableAnimated(oldCount: 0, newCount: 1)
            view.reloadRow(at: IndexPath(row: 0, section: 0))
            view.showLikeError(message: "Ошибка")

            // then
            XCTAssertTrue(view.updateTableAnimatedCalled)
            XCTAssertTrue(view.reloadRowCalled)
            XCTAssertTrue(view.showLikeErrorCalled)
        }
}
