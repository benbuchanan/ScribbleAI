//
//  ScribbleAIApp.swift
//  ScribbleAI
//
//  Created by Ben Buchanan on 3/14/23.
//

import SwiftUI

@main
struct ScribbleAIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(prompt: "")
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
