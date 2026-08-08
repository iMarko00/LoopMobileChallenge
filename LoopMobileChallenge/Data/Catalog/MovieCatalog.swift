import Foundation

@MainActor
final class MovieCatalog {
    private let allMoviesURL = URL(string: "https://apps.agentur-loop.com/challenge/movies.json")!
    private let staffPicksURL = URL(string: "https://apps.agentur-loop.com/challenge/staff_picks.json")!

    private let session: URLSession
    private let decoder: JSONDecoder

    private(set) var state: CatalogState = .idle
    private(set) var allMovieIDs: [Int] = []
    private(set) var staffPickIDs: [Int] = []
    private(set) var staffPickedMovies: [Movie] = []
    private var allMovies: [Movie] = []

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session

        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func load() async {
        state = .loading
        allMovieIDs = []
        staffPickIDs = []
        staffPickedMovies = []
        allMovies = []

        do {
            async let allMoviesTask = fetchMovies(from: allMoviesURL)
            print("Called fetchMovies(from:) with \(allMoviesURL)")
            async let staffPicksTask = fetchMovies(from: staffPicksURL)
            print("Called fetchMovies(from:) with \(staffPicksURL)")
            let (allMoviesResponse, staffPicksResponse) = try await (allMoviesTask, staffPicksTask)

            allMovies = allMoviesResponse
            allMovieIDs = allMoviesResponse.map(\.id)
            staffPickIDs = staffPicksResponse.map(\.id)
            staffPickedMovies = staffPicksResponse

            state = .loaded
        } catch {
            state = .failed(error)
        }
    }

    func movie(for id: Int) -> Movie? {
        allMovies.first(where: { $0.id == id })
    }

    private func fetchMovies(from url: URL) async throws -> [Movie] {
        print("Inside fetchMovies")
        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw CatalogError.invalidResponse(url: url)
            }
            print("Got data: \(data)")

            do {
                let movies = try decoder.decode([Movie].self, from: data)
                print("Decoded into Movies: \(movies.first)")
                return movies
            } catch {
                throw CatalogError.decodingFailed(url: url, underlying: error)
            }
        } catch let error as CatalogError {
            throw error
        } catch {
            throw CatalogError.requestFailed(url: url, underlying: error)
        }
    }
}
