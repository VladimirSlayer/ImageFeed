import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            if let image = image {
                rescaleAndCenterImageInScrollView(image: image)
            }
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var placeholderImageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    var fullImageURL: URL?
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image = image else { return }
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        placeholderImageView.isHidden = false
        loadFullImage()
    }
    
    private func loadFullImage() {
        guard let fullImageURL = fullImageURL else { return }
        print(fullImageURL)
        
        UIBlockingProgressHUD.show()

        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let imageResult):
                self.placeholderImageView.isHidden = true
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadFullImage()
        })
        
        present(alert, animated: true, completion: nil)
    }

    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        imageView.image = image

        let imageSize = image.size
        let screenSize = scrollView.bounds.size

        // Масштаб по высоте
        let scale = screenSize.height / imageSize.height
        let scaledWidth = imageSize.width * scale
        let scaledHeight = screenSize.height

        imageView.frame = CGRect(origin: .zero, size: CGSize(width: scaledWidth, height: scaledHeight))
        scrollView.contentSize = imageView.frame.size

        // Центровка по горизонтали (вдоль ширины)
        let xOffset = max((scrollView.bounds.width - scaledWidth) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: xOffset, bottom: 0, right: xOffset)

        // Устанавливаем минимальный и текущий масштаб
        scrollView.minimumZoomScale = 0.25
        scrollView.zoomScale = 1
    }
    
    private func updateContentInset() {
        let visibleRectSize = UIScreen.main.bounds.size
        let contentSize = scrollView.contentSize
        let verticalInset = max((visibleRectSize.height - contentSize.height) / 2, 0)
        let horizontalInset = max((visibleRectSize.width - contentSize.width) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        updateContentInset()
    }
}
