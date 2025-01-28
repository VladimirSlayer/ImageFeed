import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
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
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Error: Unable to create token request")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        URLSession.shared.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let token = responseBody.access_token
                    self?.tokenStorage.token = token
                    completion(.success(token))
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}
