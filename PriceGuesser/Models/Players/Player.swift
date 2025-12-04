import Foundation

struct Player: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var dateCreated: Date

    init(id: UUID = UUID(), name: String, dateCreated: Date = Date()) {
        self.id = id
        self.name = name
        self.dateCreated = dateCreated
    }
}
