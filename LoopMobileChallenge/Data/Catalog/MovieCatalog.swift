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
    private var moviesByID: [Int: Movie] = [:]

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session

        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func load() async {
        state = .loading

        do {
            async let allMoviesTask = fetchMovies(from: allMoviesURL)
            print("Called fetchMovies(from:) with \(allMoviesURL)")
            async let staffPicksTask = fetchMovies(from: staffPicksURL)
            print("Called fetchMovies(from:) with \(staffPicksURL)")
            let (allMovies, staffPicks) = try await (allMoviesTask, staffPicksTask)

            allMovieIDs = allMovies.map(\.id)
            staffPickIDs = staffPicks.map(\.id)

            var mergedByID: [Int: Movie] = [:]
            allMovies.forEach { mergedByID[$0.id] = $0 }
            staffPicks.forEach { mergedByID[$0.id] = $0 }
            moviesByID = mergedByID

            state = .loaded
        } catch {
            state = .failed(error)
        }
    }

    func movie(for id: Int) -> Movie? {
        moviesByID[id]
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
