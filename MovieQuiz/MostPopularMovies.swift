import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let fullTitle: String
    let year: String
    let crew: String
    let id: String
    let rank: String
    let rankUpDown: String
    let image: String
    let rating: String
    let ratingCount: String
    
    var resizedImageURL: URL {
        let urlString = image.components(separatedBy: "._V1_").first ?? ""
        let newUrlString = urlString + "._V1_UX600_.jpg"
        return URL(string: newUrlString) ?? URL(string: image)!
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case fullTitle
        case year
        case crew
        case id
        case rank
        case rankUpDown
        case image
        case rating = "imDbRating"
        case ratingCount = "imDbRatingCount"
    }
}
