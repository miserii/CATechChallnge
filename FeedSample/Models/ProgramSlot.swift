import Foundation

struct ProgramSlot: Codable {
    let id: String
    let channelId: String
    let title: String
    let highlight: String
    let timeState: TimeState

    enum TimeState: String, Codable {
        case past
        case present
        case future
    }
}

extension ProgramSlot {
    struct ApiProgramSlots: Codable {
        let slots: [ProgramSlot]
    }
}
