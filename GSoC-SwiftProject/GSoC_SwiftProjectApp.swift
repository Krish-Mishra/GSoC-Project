//
//  GSoC_SwiftProjectApp.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 26/02/26.
//

import SwiftUI
import SwiftData

@main
struct GSoC_SwiftProjectApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: SavedSummary.self)
        }
    }
}
