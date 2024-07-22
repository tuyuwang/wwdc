//
//  ShortcutsProvider.swift
//  AppShortcutsDemo
//
//  Created by tuyw on 2024/7/22.
//

import AppIntents
import SwiftUI

struct ExampleShortcutsDemo: AppShortcutsProvider {
    
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ExampleDialogIntent(),
            //Spotlight phrases / id
            phrases: [
                "Spotlight phrases \(.applicationName)",
            ],
            shortTitle: "example dialog",
            systemImageName: "photo.badge.plus"
        )
        AppShortcut(
            intent: ExampleCustomDialogIntent(),
            //Spotlight phrases / id
            phrases: [
                "Spotlight \(.applicationName)",
            ],
            shortTitle: "example custom dialog",
            systemImageName: "photo.badge.plus"
        )
        AppShortcut(
            intent: ExampleParameterIntent(),
            //Spotlight phrases / id
            phrases: [
                "Parameter \(.applicationName)",
            ],
            shortTitle: "parameter",
            systemImageName: "photo.badge.plus"
        )
    }
}


struct ExampleDialogIntent: AppIntent {
    static var title: LocalizedStringResource = "dialog intent"
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(dialog: "Okey, let me see see")
    }
}

struct ExampleCustomDialogIntent: AppIntent {
    static var title: LocalizedStringResource = "custom dislog intent"
    
    func perform() async throws -> some ProvidesDialog & ShowsSnippetView {
        
        return await .result(dialog: "custom dislog title", view: CustomDialogView())
        
    }
}

struct ExampleParameterIntent: AppIntent {
    static var title: LocalizedStringResource = "Parameter Intent"
    
    @Parameter(title: "Search Content")
    var searchContent: Int
    
    func perform() async throws -> some IntentResult & ProvidesDialog{
        let session = SearchMananger.shared.session(for: searchContent)
        return .result(dialog: "Result \(session?.id ?? 0) - \(session?.name ?? "")")
    }
}

struct CustomDialogView: View  {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

//Parameters

struct SearchSession: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: "Search Session pppp")
    
    let id: Int
    let name: LocalizedStringResource

    static var typeDisplayName: LocalizedStringResource = "Search Session"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: name)
    }
    static var defaultQuery = SearchSessionQuery()
}

struct SearchSessionQuery: EntityQuery {
    func entities(for identifiers: [Int]) async throws -> [SearchSession] {
        identifiers.compactMap { SearchMananger.shared.session(for: $0 )}
    }
}


class SearchMananger {
    static let shared = SearchMananger()
    
    var sessions = [
        SearchSession(id: 0, name: "session 1"),
        SearchSession(id: 1, name: "session 2"),
        SearchSession(id: 2, name: "session 3"),
        SearchSession(id: 3, name: "session 4")

    ]
    
    func session(for identifier: Int) -> SearchSession? {
        
        for session in sessions {
            if session.id == identifier {
                return session
            }
        }
        
        return nil
    }
    
}
