import Foundation

protocol DataManagerProtocol: AnyObject {
    var players: [Player] { get }
    var restaurants: [Restaurant] { get }
    var gameHistory: [Game] { get }
    var groups: [Group] { get }

    func addPlayer(_ player: Player)
    func updatePlayer(_ player: Player)
    func deletePlayer(_ player: Player)

    func addRestaurant(_ restaurant: Restaurant)
    func updateRestaurant(_ restaurant: Restaurant)
    func deleteRestaurant(_ restaurant: Restaurant)

    func addGame(_ game: Game)
    func deleteGame(_ game: Game)

    func addGroup(_ group: Group)
    func updateGroup(_ group: Group)
    func deleteGroup(_ group: Group)
    func getPlayers(for group: Group) -> [Player]

    func calculateResults(guesses: [PlayerGuess], actualPrice: Double, gameMode: GameMode) -> [GameResult]
}

extension DataManager: DataManagerProtocol {}
