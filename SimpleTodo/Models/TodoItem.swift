//
//  TodoItem.swift
//  SimpleTodo
//
//  1つのTODOを表すデータモデルです。
//

import Foundation

/// 1件のTODOを表す構造体。
///
/// - `Identifiable`: SwiftUIのListで一意に識別するために採用（`id`が必要）。
/// - `Codable`: UserDefaultsに保存するためJSONへ変換できるようにする。
/// - `Equatable`: 値の比較ができると更新処理やテストが書きやすくなる。
struct TodoItem: Identifiable, Codable, Equatable {

    /// 各TODOを区別するための一意なID。
    /// 生成時に自動採番するので、初期値として `UUID()` を入れています。
    let id: UUID

    /// TODOの内容（例: 「牛乳を買う」）。
    var title: String

    /// 完了済みかどうか。`true` なら完了、`false` なら未完了。
    var isCompleted: Bool

    /// 新しいTODOを作るための初期化メソッド。
    /// 呼び出し側では `TodoItem(title: "買い物")` のように書けます。
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
