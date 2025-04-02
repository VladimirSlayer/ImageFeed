import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    
    // MARK: - Properties
    private let showAuthenticationScreenSegueIdentifier = "showAuthorizationFlow"
    private let showPageScreenSegueIdentifier = "showProfileFlow"
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage()
    private let logoImageView = UIImageView(image: UIImage(named: "YP_Logo"))
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigate()
    }
    // MARK: - Check for token
    private func navigate(){
        if let token = storage.token {
            fetchProfile(token)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                assertionFailure("Unable to instantiate AuthViewController from storyboard")
                return
            }
            
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true, completion: nil)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YP_Black")
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 78).isActive = true
    }
}

// MARK: - Extension for switching controllers

extension SplashViewController {
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else {
            return
        }
        
        fetchProfile(token)
    }
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { imageResult in
                    switch imageResult {
                    case .success(let url):
                        print("Аватарка загружена: \(url)")
                        // Можно в будущем передать в UI
                    case .failure(let error):
                        print("Ошибка загрузки аватарки: \(error)")
                    }
                }
                self.switchToTabBarController()
                
            case .failure(let error):
                self.showProfileLoadErrorAlert(error: error)
            }
        }
    }
    private func showProfileLoadErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Не удалось загрузить профиль",
            message: "Проверьте подключение к интернету и попробуйте снова.\n\nОшибка: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let token = self?.storage.token else { return }
            self?.fetchProfile(token)
        })
        
        alert.addAction(UIAlertAction(title: "Выход", style: .destructive) { _ in
            exit(0)
        })
        
        present(alert, animated: true)
    }
}
