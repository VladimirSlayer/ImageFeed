import Foundation

struct Photos {
    let items: [Photo]
}

extension Photos {
    init(from results: [PhotoResult]) {
        self.items = results.map { Photo(from: $0) }
    }
}
