import Foundation

internal protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    func didTapLike(at index: Int)
    func willDisplayCell(at index: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService()
    
    var photosCount: Int {
        return photos.count
    }
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceivePhotosUpdate),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        imagesListService.fetchPhotosNextPage()
    }

    @objc private func didReceivePhotosUpdate() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        photos = newPhotos
        view?.updateTableAnimated(oldCount: oldCount, newCount: newPhotos.count)
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
    
    func didTapLike(at index: Int) {
        let photo = photos[index]
        let newLikeStatus = !photo.isLiked
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                self.view?.reloadRow(at: IndexPath(row: index, section: 0))
            case .failure(let error):
                self.view?.showLikeError(message: error.localizedDescription)
            }
        }
    }

    func willDisplayCell(at index: Int) {
        if index == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

