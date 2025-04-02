import Foundation

// MARK: - DTO от сервера Unsplash
struct ProfileResult: Decodable {
    let username: String
    let first_name: String
    let last_name: String?
    let bio: String?
    let email: String?
}

// MARK: - UI-модель для отображения на экране
struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

// MARK: - Сервис получения профиля
final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private(set) var profile: Profile?

    // Создание запроса к /me с токеном
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("Invalid profile URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    /// Загрузка профиля
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)

        // Защита от гонки запросов
        if let task = task {
            if lastToken != token {
                task.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else if lastToken == token {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        lastToken = token

        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastToken = nil

                switch result {
                case .success(let profileResult):
                    let fullName = [profileResult.first_name, profileResult.last_name]
                        .compactMap { $0 }
                        .joined(separator: " ")

                    let profile = Profile(
                        username: profileResult.username,
                        name: fullName,
                        loginName: "@\(profileResult.username)",
                        bio: profileResult.bio
                    )

                    self?.profile = profile
                    completion(.success(profile))

                case .failure(let error):
                    print("[ProfileService]: Failed to fetch profile - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
}
