import Foundation

enum Constants {
    static let accessKey = "-VRkNx4gbyX9LJTjx-CQyY04DhPMS4xBN33Pc1wn3Ok"
    static let secretKey = "NJI_dzvCNWrkHORIP9cU0W2X8Js-V8qu9DZNn07Xcv0"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    
    static let accessScope = "public+read_user+write_user+write_likes"

    static let defaultBaseURL: URL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}


struct AuthConfiguration{
    let accessKey: String
        let secretKey: String
        let redirectURI: String
        let accessScope: String
        let defaultBaseURL: URL
        let authURLString: String

        init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
            self.accessKey = accessKey
            self.secretKey = secretKey
            self.redirectURI = redirectURI
            self.accessScope = accessScope
            self.defaultBaseURL = defaultBaseURL
            self.authURLString = authURLString
        }
    
    static var standard: AuthConfiguration {
            return AuthConfiguration(accessKey: Constants.accessKey,
                                     secretKey: Constants.secretKey,
                                     redirectURI: Constants.redirectURI,
                                     accessScope: Constants.accessScope,
                                     authURLString: Constants.unsplashAuthorizeURLString,
                                     defaultBaseURL: Constants.defaultBaseURL)
        }
}
