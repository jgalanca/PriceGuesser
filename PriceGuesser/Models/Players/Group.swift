import Foundation

struct Group: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var playerIds: [UUID]
    let dateCreated: Date

    init(id: UUID = UUID(), name: String, playerIds: [UUID] = [], dateCreated: Date = Date()) {
        self.id = id
        self.name = name
        self.playerIds = playerIds
        self.dateCreated = dateCreated
    }
}
