import Foundation

enum CatalogState {
    case idle
    case loading
    case loaded
    case failed(Error)
}
