import Foundation

struct Movie: Codable, Equatable {
    let rating: Double
    let id: Int
    let revenue: Int
    let releaseDate: String
    let director: Director
    let posterUrl: String
    let cast: [CastMember]
    let runtime: Int
    let title: String
    let overview: String
    let reviews: Int
    let budget: Int
    let language: String
    let genres: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterUrl
        case releaseDate
        case rating
        case runtime
        case revenue
        case budget
        case reviews
        case language
        case genres
        case director
        case cast
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decode(String.self, forKey: .overview)
        posterUrl = try container.decode(String.self, forKey: .posterUrl)
        releaseDate = try container.decode(String.self, forKey: .releaseDate)
        rating = try container.decode(Double.self, forKey: .rating)
        runtime = try container.decode(Int.self, forKey: .runtime)
        revenue = try container.decodeIfPresent(Int.self, forKey: .revenue) ?? 0
        budget = try container.decode(Int.self, forKey: .budget)
        reviews = try container.decode(Int.self, forKey: .reviews)
        language = try container.decode(String.self, forKey: .language)
        genres = try container.decode([String].self, forKey: .genres)
        director = try container.decode(Director.self, forKey: .director)
        cast = try container.decode([CastMember].self, forKey: .cast)
    }
}

extension Movie {
    struct Director: Codable, Equatable {
        let name: String
        let pictureUrl: String
    }

    struct CastMember: Codable, Equatable {
        let name: String
        let pictureUrl: String
        let character: String
    }
}
