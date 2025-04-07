import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private(set) var photos = Photos(items: [])
    private var lastLoadedPage: Int?
    private var isFetching = false
    private let token = OAuth2TokenStorage()

    func fetchPhotosNextPage() {
        guard !isFetching else { return }

        isFetching = true
        let nextPage = (lastLoadedPage ?? 0) + 1

        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10") else {
            isFetching = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

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
                let newPhotos = Photos(from: photoResults)

                DispatchQueue.main.async {
                    self.photos = Photos(items: self.photos.items + newPhotos.items)
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
}
