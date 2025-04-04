import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profilePicture = UIImageView(image: UIImage(named: "Photo"))
    private let nameLabel = UILabel()
    private let tagLabel = UILabel()
    private let bioLabel = UILabel()
    private let buttonView = UIButton()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateProfileInfo()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profilePicture.kf.setImage(with: url,
                                   options: [.processor(processor)])
    }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YP_Black")
        
        [profilePicture, nameLabel, tagLabel, bioLabel, buttonView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Constraints
        profilePicture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        profilePicture.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profilePicture.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profilePicture.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        profilePicture.contentMode = .scaleAspectFit
        profilePicture.clipsToBounds = true
        
        nameLabel.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: profilePicture.leadingAnchor).isActive = true
        
        tagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        tagLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        
        bioLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 8).isActive = true
        bioLabel.leadingAnchor.constraint(equalTo: tagLabel.leadingAnchor).isActive = true
        
        buttonView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        buttonView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        buttonView.centerYAnchor.constraint(equalTo: profilePicture.centerYAnchor).isActive = true
        buttonView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        
        // Styles
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        tagLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        tagLabel.textColor = UIColor(named: "YP_Gray")
        
        bioLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        bioLabel.textColor = .white
        
        buttonView.setImage(UIImage(named: "exit_button"), for: .normal)
    }
    
    private func updateProfileInfo() {
        guard let profile = ProfileService.shared.profile else {
            print("Профиль отсутствует")
            return
        }
        
        updateProfileDetails(profile: profile)
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        tagLabel.text = profile.loginName
        bioLabel.text = profile.bio
    }
}
