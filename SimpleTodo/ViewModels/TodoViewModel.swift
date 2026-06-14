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
    /// - Parameters:
    ///   - title:    入力された文字列。前後の空白は取り除きます。
    ///   - priority: 優先度（デフォルトは `.medium`）。
    func addTodo(title: String, priority: Priority = .medium) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        items.append(TodoItem(title: trimmed, priority: priority))
        save()
    }

    /// 指定したTODOの優先度を変更します。
    func setPriority(_ priority: Priority, for item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].priority = priority
        save()
    }

    /// 指定したTODO（親）の「完了 / 未完了」を切り替えます。
    ///
    /// - サブタスクが無い場合: これまで通り親の状態だけを反転します。
    /// - サブタスクがある場合: 全サブタスクをまとめて同じ状態にし、親もそれに合わせます。
    ///   （「全サブタスク完了 ⇔ 親完了」という整合性を保つため）
    func toggleCompletion(for item: TodoItem) {
        // 配列の中から該当TODOの位置を探します。
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        if items[index].subtasks.isEmpty {
            items[index].isCompleted.toggle()
        } else {
            let newValue = !items[index].isCompleted
            for j in items[index].subtasks.indices {
                items[index].subtasks[j].isCompleted = newValue
            }
            items[index].isCompleted = newValue
        }
        save()
    }

    /// 指定したTODO（親）を1件削除します。サブタスクも一緒に削除されます
    /// （サブタスクは親の中に内包されているため、親を消せば自動的に消えます）。
    func delete(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    /// スワイプ削除用。Listが渡してくる位置情報(IndexSet)で削除します。
    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    // MARK: - サブタスク操作

    /// 指定した親TODOにサブタスクを追加します。
    func addSubtask(to item: TodoItem, title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        items[index].subtasks.append(SubTask(title: trimmed))
        // 未完了のサブタスクが増えたら親の完了状態を再計算します。
        recomputeCompletion(at: index)
        save()
    }

    /// サブタスクの「完了 / 未完了」を切り替えます。
    /// 切り替え後、親TODOの完了状態を自動で再計算します。
    func toggleSubtask(_ subtask: SubTask, in item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        guard let subIndex = items[index].subtasks.firstIndex(where: { $0.id == subtask.id }) else { return }

        items[index].subtasks[subIndex].isCompleted.toggle()
        recomputeCompletion(at: index)
        save()
    }

    /// 指定したサブタスクのみを削除します（親は残ります）。
    func deleteSubtask(_ subtask: SubTask, from item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        items[index].subtasks.removeAll { $0.id == subtask.id }
        recomputeCompletion(at: index)
        save()
    }

    // MARK: - 内部処理

    /// 親TODOの完了状態を、サブタスクの状態から自動で決め直します。
    /// 「全サブタスクが完了 → 親も完了」「1件でも未完了 → 親は未完了」。
    /// サブタスクが無い親は手動の完了状態をそのまま尊重します。
    private func recomputeCompletion(at index: Int) {
        let subtasks = items[index].subtasks
        guard !subtasks.isEmpty else { return }
        items[index].isCompleted = subtasks.allSatisfy { $0.isCompleted }
    }

    /// 現在のTODO一覧を端末に保存します。
    /// 追加・切り替え・削除のたびに呼ぶことで、アプリ終了後もデータが残ります。
    private func save() {
        storage.save(items)
    }
}
