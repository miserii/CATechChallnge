import Foundation

final class MockApiSession {

    static let shared = MockApiSession()

    func fetchChannels() -> [Channel] {
        guard
            let path = Bundle.main.path(forResource: "channels", ofType: "json"),
            let jsonData = try? getJSONData(path: path),
            let apiChannels = try? JSONDecoder().decode(Channel.ApiChannels.self, from: jsonData)
        else { return [] }
        return apiChannels.channels
    }

    func fetchBroadcastSlots() -> [BroadcastSlot]  {
        guard
            let path = Bundle.main.path(forResource: "broadcast", ofType: "json"),
            let jsonData = try? getJSONData(path: path),
            let apiBroadcastSlots = try? JSONDecoder().decode(BroadcastSlot.ApiBroadcastSlots.self, from: jsonData)
        else { return [] }
        return apiBroadcastSlots.slots
    }

    func fetchProgramSlots() -> [ProgramSlot]  {
        guard
            let path = Bundle.main.path(forResource: "program", ofType: "json"),
            let jsonData = try? getJSONData(path: path),
            let apiProgramSlots = try? JSONDecoder().decode(ProgramSlot.ApiProgramSlots.self, from: jsonData)
        else { return [] }
        return apiProgramSlots.slots
    }

    func fetchComments() -> [Comment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted({
            let f = DateFormatter()
            f.calendar = Calendar(identifier: .gregorian)
            f.locale = .current
            f.dateFormat = "yyyyMMddHHmmssSS"
            return f
        }())
        guard let path = Bundle.main.path(forResource: "comments", ofType: "json"),
            let jsonData = try? getJSONData(path: path),
            let apiComments = try? decoder.decode(Comment.ApiComments.self, from: jsonData)
        else { return [] }
        return apiComments.comments
    }

    private func getJSONData(path: String) throws -> Data {
        let url = URL(fileURLWithPath: path)
        return try Data(contentsOf: url)
    }
}
