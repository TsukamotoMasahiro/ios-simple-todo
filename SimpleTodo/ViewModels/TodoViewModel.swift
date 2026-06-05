//
//  TodoViewModel.swift
//  SimpleTodo
//
//  画面(View)とデータ(Model)の橋渡しをするViewModelです。
//  MVVMの「VM」にあたり、TODOの追加・切り替え・削除などの
//  「ロジック」をここに集約します。Viewは表示に専念できます。
//

import Foundation

/// TODO一覧の状態と操作をまとめたViewModel。
///
/// - `@MainActor`: UI更新は必ずメインスレッドで行う必要があるため指定しています。
/// - `ObservableObject`: `@Published` の変更をViewに自動通知するための仕組みです。
@MainActor
final class TodoViewModel: ObservableObject {

    /// 画面に表示するTODOの一覧。
    /// `@Published` を付けると、この配列が変わるたびにViewが自動で再描画されます。
    @Published private(set) var items: [TodoItem] = []

    /// 保存・読み込みを担当するストレージ。
    private let storage: TodoStorage

    // MARK: - 表示用の計算プロパティ

    /// TODOの総件数。
    var totalCount: Int {
        items.count
    }

    /// 未完了のTODO件数。件数表示に使います。
    var remainingCount: Int {
        items.filter { !$0.isCompleted }.count
    }

    /// TODOが1件も無いかどうか。Empty State表示の判定に使います。
    var isEmpty: Bool {
        items.isEmpty
    }

    // MARK: - 初期化

    /// 初期化時に保存済みのTODOを読み込みます。
    init(storage: TodoStorage = TodoStorage()) {
        self.storage = storage
        self.items = storage.load()
    }

    // MARK: - 操作（ユーザー操作に対応するメソッド）

    /// 新しいTODOを追加します。
    /// - Parameter title: 入力された文字列。前後の空白は取り除きます。
    func addTodo(title: String) {
        // 前後の空白・改行を除去します。
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        // 空文字だけの追加は無視します（誤操作防止）。
        guard !trimmed.isEmpty else { return }

        items.append(TodoItem(title: trimmed))
        save()
    }

    /// 指定したTODOの「完了 / 未完了」を切り替えます。
    func toggleCompletion(for item: TodoItem) {
        // 配列の中から該当TODOの位置を探します。
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isCompleted.toggle()
        save()
    }

    /// 指定したTODOを1件削除します（削除ボタン用）。
    func delete(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    /// スワイプ削除用。Listが渡してくる位置情報(IndexSet)で削除します。
    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    // MARK: - 内部処理

    /// 現在のTODO一覧を端末に保存します。
    /// 追加・切り替え・削除のたびに呼ぶことで、アプリ終了後もデータが残ります。
    private func save() {
        storage.save(items)
    }
}
