import UIKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?

    func viewDidLoad() {
        guard let profile = ProfileService.shared.profile else {
            print("Профиль отсутствует")
            return
        }
        
        view?.updateProfileDetails(profile: profile)
        
        if let avatarURL = ProfileImageService.shared.avatarURL,
           let url = URL(string: avatarURL) {
            view?.updateAvatar(with: url)
        }
    }

    func didTapLogout() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        if let viewController = view as? UIViewController {
            viewController.present(alert, animated: true)
        }
    }
}
