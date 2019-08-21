import Foundation

final class MockApiSession {

    static let shared = MockApiSession()

    func fetchChannels() -> [Channel] {

        guard let path = Bundle.main.path(forResource: "channels", ofType: "json"),
            let jsonData = try? getJSONData(path: path),
            let apiChannels = try? JSONDecoder().decode(Channel.ApiChannels.self, from: jsonData!) else {
                return []
        }
        return apiChannels.channels
    }

    func fetchBroadcastSlots() -> [BroadcastSlot]  {
        
        guard let path = Bundle.main.path(forResource: "broadcast", ofType: "json"),
            let jsonData = try? getJSONData(path: path),
            let apiBroadcastSlots = try? JSONDecoder().decode(BroadcastSlot.ApiBroadcastSlots.self, from: jsonData!) else {
                return []
        }
        return apiBroadcastSlots.slots
    }

    func fetchProgramSlots() -> [ProgramSlot]  {

        guard let path = Bundle.main.path(forResource: "program", ofType: "json"),
            let jsonData = try? getJSONData(path: path) else {
                return []
        }

        do {
            let apiProgramSlots = try JSONDecoder().decode(ProgramSlot.ApiProgramSlots.self, from: jsonData!)
            return apiProgramSlots.slots
        } catch {
            print("\(error.localizedDescription)")
            return []
        }
    }

    private func getJSONData(path: String) throws -> Data? {
        let url = URL(fileURLWithPath: path)

        return try Data(contentsOf: url)
    }
}
