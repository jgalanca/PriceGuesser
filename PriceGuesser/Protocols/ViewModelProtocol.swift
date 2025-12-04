import SwiftUI

@MainActor
protocol ViewModelProtocol: AnyObject, Observable {
    associatedtype DataManager: DataManagerProtocol
    var dataManager: DataManager { get }
}
