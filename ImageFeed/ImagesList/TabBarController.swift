import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            assertionFailure("Не удалось привести ImagesListViewController")
            return
        }
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.configure(presenter: imagesListPresenter)
        let profileViewController = ProfileViewController()
        let presenter = ProfilePresenter()
        profileViewController.configure(presenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        viewControllers = [imagesListViewController, profileViewController]
    }
}

