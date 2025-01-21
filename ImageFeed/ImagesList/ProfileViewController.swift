import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupUI() {
        let profilePicture = UIImageView(image: UIImage(named: "Photo"))
        let nameLabel = UILabel()
        let tagLabel = UILabel()
        let bioLabel = UILabel()
        let buttonView = UIButton()
        view.backgroundColor = UIColor(named: "YP_Black")
        
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profilePicture)
        view.addSubview(nameLabel)
        view.addSubview(tagLabel)
        view.addSubview(bioLabel)
        view.addSubview(buttonView)
        
        profilePicture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        profilePicture.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: profilePicture.leadingAnchor).isActive = true
        
        tagLabel.text = "@ekaterina_novikova"
        tagLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        tagLabel.textColor = UIColor(named: "YP_Gray")
        tagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        tagLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        
        bioLabel.text = "Hello, world!"
        bioLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        bioLabel.textColor = .white
        bioLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 8).isActive = true
        bioLabel.leadingAnchor.constraint(equalTo: tagLabel.leadingAnchor).isActive = true
        
        buttonView.setImage(UIImage(named: "exit_button"), for: .normal)
        buttonView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        buttonView.heightAnchor.constraint(equalToConstant: 24).isActive = true

        buttonView.centerYAnchor.constraint(equalTo: profilePicture.centerYAnchor).isActive = true
        buttonView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
    }
    
    
}
