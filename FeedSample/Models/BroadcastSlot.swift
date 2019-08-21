import Foundation

struct BroadcastSlot: Codable {
    let id: String
    let title: String
    let channelId: String
    let highlight: String
    let stats: Stats
}

extension BroadcastSlot {
    struct ApiBroadcastSlots: Codable {
        let slots: [BroadcastSlot]
    }
}
