import Foundation

enum CatalogError: Error {
    case invalidResponse(url: URL)
    case requestFailed(url: URL, underlying: Error)
    case decodingFailed(url: URL, underlying: Error)
}
