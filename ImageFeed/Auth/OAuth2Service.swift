import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private init() {}
    private var task: URLSessionTask?
    private var lastCode: String?
    private let urlSession = URLSession.shared
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        if let existingTask = task {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            } else {
                existingTask.cancel()
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }

        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil
                self.lastCode = nil

                switch result {
                case .success(let responseBody):
                    let token = responseBody.access_token
                    self.tokenStorage.token = token
                    completion(.success(token))
                case .failure(let error):
                    print("[OAuth2Service]: Failed to fetch token - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }

        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Error: Invalid base URL")
            return nil
        }
        
        let endpoint = "/oauth/token"
        let query = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        var urlComponents = URLComponents(string: endpoint)
        urlComponents?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents?.url(relativeTo: baseURL) else {
            print("Error: Unable to construct URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
