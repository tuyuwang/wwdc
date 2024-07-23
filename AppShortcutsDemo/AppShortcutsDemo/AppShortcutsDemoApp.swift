//
//  AppShortcutsDemoApp.swift
//  AppShortcutsDemo
//
//  Created by tuyw on 2024/7/22.
//

import SwiftUI
import AppIntents

@main
struct AppShortcutsDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        AppDependencyManager.shared.add(dependency: SearchMananger.shared)
    }
}
