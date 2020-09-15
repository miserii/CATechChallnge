import Foundation

struct Channel: Codable {
    let id: String
    let name: String
    let url: String
    let mp4: String
    
}

extension Channel {
    struct ApiChannels: Codable {
        let channels: [Channel]
    }
}
