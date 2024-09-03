//
//  ShortcutsProvider.swift
//  AppShortcutsDemo
//
//  Created by tuyw on 2024/7/22.
//

import AppIntents
import SwiftUI

//struct ExampleShortcutsDemo: AppShortcutsProvider {
//    
//    
//    static var appShortcuts: [AppShortcut] {
//        AppShortcut(
//            intent: ExampleDialogIntent(),
//            //Spotlight phrases / id
//            phrases: [
//                "Spotlight phrases \(.applicationName)",
//            ],
//            shortTitle: "example dialog",
//            systemImageName: "square.and.arrow.up.circle.fill"
//        )
//        AppShortcut(
//            intent: ExampleCustomDialogIntent(),
//            //Spotlight phrases / id
//            phrases: [
//                "Spotlight \(.applicationName)",
//            ],
//            shortTitle: "example custom dialog",
//            systemImageName: "photo.badge.plus"
//        )
//        AppShortcut(
//            intent: ExampleParameterIntent(),
//            //Spotlight phrases / id
//            phrases: [
//                "Parameter \(.applicationName)",
//            ],
//            shortTitle: "parameter",
//            systemImageName: "photo.badge.plus"
//        )
//    }
//}


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



// MARK: Demo
struct ShortcustDemo: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: HelloWorldAppIntent(),
            phrases: [
                "output hello world \(.applicationName)",
            ],
            shortTitle: "show a dialog",
            systemImageName: "heart.circle.fill")
        AppShortcut(
            intent: HelloWorldArgsAppIntent(),
            phrases: [
                "output hello world args \(.applicationName)",
            ],
            shortTitle: "args intent",
            systemImageName: "heart.circle.fill")
        AppShortcut(
            intent: HelloWorldReceiveArgsAppIntent(),
            phrases: [
                "receive hello world args \(.applicationName)",
            ],
            shortTitle: "args receive intent",
            systemImageName: "heart.circle.fill")
        AppShortcut(
            intent: HelloWorldObjectArgsAppIntent(),
            phrases: [
                "output hello world obj args \(.applicationName)",
            ],
            shortTitle: "obj args intent",
            systemImageName: "heart.circle.fill")
        AppShortcut(
            intent: HelloWorldRecieveObjectArgsAppIntent(),
            phrases: [
                "receive hello world obj args \(.applicationName)",
            ],
            shortTitle: "receive obj args intent",
            systemImageName: "heart.circle.fill")
    }
}

struct HelloWorldAppIntent: AppIntent {
    
    static var title: LocalizedStringResource = "展示一个Hello World弹窗"
    
    func perform() async throws -> some ReturnsValue<String> & ShowsSnippetView {
        return await .result(value: "展示一个Hello World弹窗", view: CustomDialogView())
    }

}



struct HelloWorldArgsAppIntent: AppIntent {
    
    static var title: LocalizedStringResource = "展示一个基本数据类型参数"
    
    @Parameter(title: "内容", description: "描述文案")
    var input: String
    
    @Parameter(title: "开关")
    var switchState: Bool
    
    @Parameter(title: "数字")
    var number: Int
    
    static var parameterSummary: some ParameterSummary {
        Summary("请输入\(\.$input), 选择\(\.$switchState), 数字\(\.$number)")
    }
    
    func perform() async throws -> some ReturnsValue<String>  {
        
        return .result(value: "输入结果: \(self.input) - \(self.switchState) - \(self.number)")
    }

}

struct HelloWorldReceiveArgsAppIntent: AppIntent {
    
    static var title: LocalizedStringResource = "接收一个基本数据类型参数"
    
    @Parameter(title: "输入的内容")
    var input: String
    
    
    func perform() async throws -> some ReturnsValue<String>  {
        
        return .result(value: "接受上一个指令的值: \(self.input)")
    }

}

struct HelloWorldObjectArgsAppIntent: AppIntent {
    
    static var title: LocalizedStringResource = "展示一个对象类型参数"
    
    @Parameter(title: "对象参数")
    var input: HelloWorldBookEntity
    
    @Parameter(title: "对象参数1")
    var input1: HelloWorldBookEntity
    
//    @Parameter(title: "基本数据")
//    var args: Int
    
//    @Parameter(title: "金额")
//    var p: IntentPerson
//    @Parameter(title: "URL")
//    var url: URL
    
    func perform() async throws -> some ReturnsValue<[HelloWorldBookEntity]>  {
        
        return .result(value: [self.input, self.input1])
    }

}

struct HelloWorldRecieveObjectArgsAppIntent: AppIntent {
    
    static var title: LocalizedStringResource = "接受一个对象类型参数"
    
    @Parameter(title: "对象参数")
    var inputs: [HelloWorldBookEntity]
    
    
    func perform() async throws -> some ReturnsValue<String>  {
        let names = self.inputs.map{ $0.name }
        return .result(value: "接受上一个指令的值: \(names)")
    }

}

struct HelloWorldBookEntity: AppEntity {
   
    
    let id: Int
    
    @Property(title: "书名")
    var name: String
    
    
    @Property(title: "价格")
    var amount: Double
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)-\(amount)")
    }
    
    typealias DefaultQuery = HelloWorldBookEntityQuery
    static var defaultQuery: HelloWorldBookEntityQuery = HelloWorldBookEntityQuery()
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(stringLiteral: "TypeDisplayRepresentation")
    
    init(id: Int, name: String, amount: Double) {
        self.id = id
        self.name = name
        self.amount = amount
    }
    
}
 

struct HelloWorldBookEntityQuery: EntityQuery {
    
    var mocks: [HelloWorldBookEntity] = [
        HelloWorldBookEntity(id: 0, name: "红楼梦", amount: 20),
        HelloWorldBookEntity(id: 1, name: "西游记", amount: 30),
        HelloWorldBookEntity(id: 2, name: "三国演义", amount: 40.6)

    ]
    
    func query(id: Int) -> HelloWorldBookEntity? {
        for entity in mocks {
            if (entity.id == id) {
                return entity
            }
            
        }
        return nil
    }
    
    func entities(for identifiers: [HelloWorldBookEntity.ID]) async throws -> [HelloWorldBookEntity] {
    
        let result = identifiers.compactMap{ query(id: $0)}
        return result
    }
    
    func suggestedEntities() async throws -> [HelloWorldBookEntity] {
        return mocks
    }
    
}
