import Foundation
import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    static let shared = ImagesListService()
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isFetching = false
    private let tokenStorage = OAuth2TokenStorage()
    
    func clearPhotos() {
        photos = []
    }

    func fetchPhotosNextPage() {
        guard !isFetching else { return }

        isFetching = true
        let nextPage = (lastLoadedPage ?? 0) + 1

        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10") else {
            isFetching = false
            return
        }

        var request = URLRequest(url: url)
        if let token = tokenStorage.token {
            print(token)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            isFetching = false
            print("Отсутствует токен")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.isFetching = false }

            if let error = error {
                print("Ошибка загрузки: \(error)")
                return
            }

            guard let data = data else {
                print("Пустой ответ от сервера")
                return
            }

            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { Photo(from: $0) }

                DispatchQueue.main.async {
                    self.photos += newPhotos
                    self.lastLoadedPage = nextPage

                    NotificationCenter.default.post(
                        name: Self.didChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos]
                    )
                }
            } catch {
                print("Ошибка при декодировании JSON: \(error)")
            }
        }

        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = tokenStorage.token else {
            print("❌ Нет токена")
            completion(.failure(NSError(domain: "No token", code: 401)))
            return
        }
        print(token)
        print(photoId)

        let httpMethod = isLike ? "POST" : "DELETE"
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Ошибка при \(isLike ? "лайке" : "дизлайке"): \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Некорректный ответ сервера")
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                    return
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    let status = httpResponse.statusCode
                    let message = HTTPURLResponse.localizedString(forStatusCode: status)
                    print("❌ Сервер вернул код: \(status) — \(message)")

                    if let data = data, let body = String(data: data, encoding: .utf8) {
                        print("📩 Ответ от сервера: \(body)")
                    }

                    completion(.failure(NSError(domain: "Bad status code", code: status)))
                    return
                }

                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )

                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)

                    // Можно отправить нотификацию, чтобы обновить UI
                    NotificationCenter.default.post(
                        name: Self.didChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos]
                    )
                }

                print("✅ \(isLike ? "Лайк" : "Дизлайк") выполнен и обновлён в модели")
                completion(.success(()))
            }
        }

        task.resume()
    }

}
