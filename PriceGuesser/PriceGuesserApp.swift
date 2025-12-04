//
//  PriceGuesserApp.swift
//  PriceGuesser
//
//  Created by Galan Cardeñosa Javier on 14/11/25.
//

import SwiftUI
import OSLog

@main
struct PriceGuesserApp: App {
    @State private var dependencies = DependencyContainer.shared

    init() {
        HapticManager.prepare()
        AppLogger.lifecycle.info("App launched")
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(dependencies.dataManager)
                .environment(dependencies.router)
                .environment(dependencies.settings)
                .preferredColorScheme(dependencies.settings.selectedAppearance.colorScheme)
                .appLifecycle()
        }
    }
}
