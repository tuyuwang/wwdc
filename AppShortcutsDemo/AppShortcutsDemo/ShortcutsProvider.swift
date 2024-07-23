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

struct ExampleParameterEntityIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Session Infomation"
    static var description: IntentDescription = IntentDescription("Session Description", categoryName: "Editing", searchKeywords: ["tuyw"])
    
    @Dependency
    private var manager: SearchMananger
    
    @Parameter(title: "Session", description: "a session")
    var session: SearchSession
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get information on \(\.$session)")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<SearchSession> & ProvidesDialog & ShowsSnippetView {
        let dialog = IntentDialog(full: "The latest conditions reported for \(session.name).",
                                  supporting: "Here's the latest information on trail conditions.")
        
        return .result(value: session, dialog: dialog, view: CustomDialogEntityView(entity: session))
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

struct CustomDialogEntityView: View {
    
    var entity: SearchSession
    
    var body: some View {
        VStack {
            Image(systemName: entity.imageName)
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(entity.name)
        }
        .padding()
    }
}

//Parameters

struct SearchSession: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: "Search Session pppp")
    
    let id: Int
    
    @Property(title: "Session Name")
    var name: String
    
    @Property(title: "Session Image")
    var imageName: String

    static var typeDisplayName: LocalizedStringResource = "Search Session"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", image: DisplayRepresentation.Image(named: imageName))
    }
    static var defaultQuery = SearchSessionQuery()
    
    
    init(id: Int, name: String, imageName: String) {
        self.id = id
        self.name = name
        self.imageName = imageName
    }
}

struct SearchSessionQuery: EntityQuery {
    
    @Dependency
    var manager: SearchMananger
    
    func entities(for identifiers: [Int]) async throws -> [SearchSession] {
        identifiers.compactMap { manager.session(for: $0 )}
    }
    
    func suggestedEntities() async throws -> [SearchSession] {
        return manager.sessions
    }
}


@Observable class SearchMananger: @unchecked Sendable {
    static let shared = SearchMananger()
    
    let sessions: [SearchSession]
    
    func session(for identifier: Int) -> SearchSession? {
        
        for session in sessions {
            if session.id == identifier {
                return session
            }
        }
        
        return nil
    }
    
    init() {
        self.sessions = [
            SearchSession(id: 0, name: "session 1", imageName: "photo.badge.plus"),
            SearchSession(id: 1, name: "session 2", imageName: "photo.badge.plus"),
            SearchSession(id: 2, name: "session 3", imageName: "photo.badge.plus"),
            SearchSession(id: 3, name: "session 4", imageName: "photo.badge.plus"),

        ]
    }
    
}
