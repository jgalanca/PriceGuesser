import Foundation

struct Restaurant: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var googleMapsLink: String?
    var dateCreated: Date

    init(id: UUID = UUID(), name: String, googleMapsLink: String? = nil, dateCreated: Date = Date()) {
        self.id = id
        self.name = name
        self.googleMapsLink = googleMapsLink
        self.dateCreated = dateCreated
    }
}
