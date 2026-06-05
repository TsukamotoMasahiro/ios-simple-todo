//
//  TodoStorage.swift
//  SimpleTodo
//
//  TODOの保存と読み込みを担当するユーティリティです。
//  ここでは外部ライブラリやクラウドを使わず、端末内の
//  「UserDefaults」にJSONとして保存します。
//

import Foundation

/// TODOの永続化（保存・読み込み）を担当する型。
///
/// ViewModelからこの型を通して保存/読み込みを行うことで、
/// 「保存の仕組み」と「画面のロジック」を分離できます（責務の分離）。
struct TodoStorage {

    /// UserDefaultsに保存する際のキー（保存場所の名前）。
    /// 文字列を直接書くとタイプミスしやすいので定数にしています。
    private let storageKey = "com.tsukamoto.simpletodo.items"

    /// 保存先のUserDefaults。通常は `.standard` を使います。
    private let defaults: UserDefaults

    /// テストなどで差し替えられるよう、UserDefaultsを外から渡せるようにしています。
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// TODO配列をJSONに変換してUserDefaultsへ保存します。
    func save(_ items: [TodoItem]) {
        do {
            // Swiftの配列をJSONのバイナリデータに変換（エンコード）します。
            let data = try JSONEncoder().encode(items)
            defaults.set(data, forKey: storageKey)
        } catch {
            // 学習用アプリなので、失敗時はコンソールに出力するだけにしています。
            print("TODOの保存に失敗しました: \(error)")
        }
    }

    /// UserDefaultsからTODO配列を読み込みます。
    /// 保存データが無い・壊れている場合は空配列を返します。
    func load() -> [TodoItem] {
        // 保存データがまだ無ければ、空のリストから始めます。
        guard let data = defaults.data(forKey: storageKey) else {
            return []
        }
        do {
            // JSONデータをSwiftの配列に戻します（デコード）。
            return try JSONDecoder().decode([TodoItem].self, from: data)
        } catch {
            print("TODOの読み込みに失敗しました: \(error)")
            return []
        }
    }
}
