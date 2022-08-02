//
//  Sporting_GOApp.swift
//  Sporting GO
//
//  Created by AppleSHSM on 2022-07-22.
//

import SwiftUI

@main
struct Sporting_GOApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
