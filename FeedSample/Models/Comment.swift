import Foundation

struct Comment: Codable {
    let id: String
    let userId: String
    let message: String
    let createdAt: Date
}

extension Comment {
    struct ApiComments: Codable {
        let comments: [Comment]
    }
}
