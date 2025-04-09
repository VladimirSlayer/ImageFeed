import Foundation
import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    var fullImageURL: URL? {
        return URL(string: largeImageURL)
    }
}

extension Photo {
    init(from result: PhotoResult) {
        let formatter = ISO8601DateFormatter()
        let date = result.createdAt.flatMap { formatter.date(from: $0) }

        self.init(
            id: result.id,
            size: CGSize(width: CGFloat(result.width ?? 0), height: CGFloat(result.height ?? 0)),
            createdAt: date,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
}

