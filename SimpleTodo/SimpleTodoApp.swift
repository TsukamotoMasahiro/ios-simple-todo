//
//  SimpleTodoApp.swift
//  SimpleTodo
//
//  アプリの「入口（エントリーポイント）」です。
//  iOSはここから起動し、最初に表示する画面を決めます。
//

import SwiftUI

// `@main` はこの構造体がアプリの起動地点であることを示します。
@main
struct SimpleTodoApp: App {
    var body: some Scene {
        // WindowGroupは1つのウィンドウ（iPhoneでは1画面）を表します。
        WindowGroup {
            // 最初に表示する画面としてメイン画面を指定します。
            ContentView()
        }
    }
}
