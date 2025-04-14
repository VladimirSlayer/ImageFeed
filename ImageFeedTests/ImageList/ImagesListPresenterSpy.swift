@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
        var view: ImagesListViewControllerProtocol?
        var viewDidLoadCalled = false
        var didTapLikeCalled = false
        var willDisplayCellCalled = false
        var photoCalledIndex: Int?
        
        var photosCount: Int = 1
        
        func viewDidLoad() {
            viewDidLoadCalled = true
        }
        
        func photo(at index: Int) -> Photo {
            photoCalledIndex = index
            return Photo(
                id: "id",
                size: CGSize(width: 100, height: 100),
                createdAt: Date(),
                welcomeDescription: "desc",
                thumbImageURL: "https://url",
                largeImageURL: "https://largeurl",
                isLiked: true
            )
        }

        func didTapLike(at index: Int) {
            didTapLikeCalled = true
            photoCalledIndex = index
        }

        func willDisplayCell(at index: Int) {
            willDisplayCellCalled = true
            photoCalledIndex = index
        }
    }
