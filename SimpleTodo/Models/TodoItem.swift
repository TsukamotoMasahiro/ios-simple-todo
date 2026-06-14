//
//  TodoItem.swift
//  SimpleTodo
//
//  1つのTODO（親）と、そのサブタスク（子）を表すデータモデルです。
//

import Foundation

// MARK: - Priority

/// TODOの優先度。
///
/// String の rawValue を使うことで、JSON に人間が読める文字列で保存されます。
/// `CaseIterable` に対応し、Picker や Menu で全ケースを列挙できます。
enum Priority: String, Codable, CaseIterable {
    case high   = "high"
    case medium = "medium"
    case low    = "low"
}

// MARK: - CompletionStatus

/// 親TODOの完了状態を3段階で表します（サブタスクの進捗率から算出）。
///
/// - `none`    : 0%（未着手）       → ○
/// - `partial` : 1〜99%（一部完了） → ◐
/// - `complete`: 100%（全完了）     → ✓
///
/// サブタスクが無い場合は `isCompleted` の true/false に対応します。
enum CompletionStatus: Equatable {
    case none
    case partial
    case complete
}

// MARK: - SubTask

/// サブタスク（子TODO）を表す構造体。
///
/// 親である `TodoItem` の中に配列として保持されます。
struct SubTask: Identifiable, Codable, Equatable {

    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

// MARK: - TodoItem

/// 1件のTODO（親）を表す構造体。
struct TodoItem: Identifiable, Codable, Equatable {

    let id: UUID
    var title: String

    /// 完了済みかどうか。サブタスクがある場合はVM側で自動更新されます。
    var isCompleted: Bool

    /// ぶら下がるサブタスクの一覧（無い場合は空配列）。
    var subtasks: [SubTask]

    /// 優先度。旧データ互換のため、デコード時は `.medium` をデフォルトにします。
    var priority: Priority

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        subtasks: [SubTask] = [],
        priority: Priority = .medium
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.subtasks = subtasks
        self.priority = priority
    }

    // MARK: - 表示用の計算プロパティ

    var hasSubtasks: Bool { !subtasks.isEmpty }

    var completedSubtaskCount: Int { subtasks.filter { $0.isCompleted }.count }

    /// 3段階の完了状態を返します。
    ///
    /// サブタスクなし → `isCompleted` の値をそのまま変換。
    /// サブタスクあり → 完了割合で `none` / `partial` / `complete` を返します。
    var completionStatus: CompletionStatus {
        if subtasks.isEmpty {
            return isCompleted ? .complete : .none
        }
        let done = completedSubtaskCount
        if done == 0               { return .none }
        if done == subtasks.count  { return .complete }
        return .partial
    }

    // MARK: - 後方互換デコード

    private enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, subtasks, priority
    }

    /// カスタムデコード。
    /// `subtasks` / `priority` キーが無い旧データも安全に復元できます。
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id          = try c.decode(UUID.self,    forKey: .id)
        title       = try c.decode(String.self,  forKey: .title)
        isCompleted = try c.decode(Bool.self,    forKey: .isCompleted)
        // 旧データには subtasks / priority キーが無いのでフォールバック。
        subtasks = try c.decodeIfPresent([SubTask].self, forKey: .subtasks) ?? []
        priority = try c.decodeIfPresent(Priority.self,  forKey: .priority) ?? .medium
    }

    // encode(to:) は CodingKeys が全プロパティを網羅しているため
    // コンパイラが自動生成します（subtasks / priority も保存されます）。
}
