//
//  ContentView.swift
//  SimpleTodo
//
//  アプリのメイン画面（1画面構成）です。
//

import SwiftUI

// MARK: - Priority 表示用拡張（Viewレイヤー専用）

private extension Priority {
    /// 一覧行に表示するラベル文字列。
    var displayLabel: String {
        switch self {
        case .high:   return "HIGH"
        case .medium: return "MED"
        case .low:    return "LOW"
        }
    }

    /// メニューや案内テキスト用の日本語表示。
    var localizedLabel: String {
        switch self {
        case .high:   return "高"
        case .medium: return "中"
        case .low:    return "低"
        }
    }

    /// 優先度を表す色。HIG: 赤＝高 / オレンジ＝中 / 青＝低。
    var tintColor: Color {
        switch self {
        case .high:   return .red
        case .medium: return .orange
        case .low:    return .blue
        }
    }

    /// 入力バーの優先度 Menu で使う SF Symbol。
    var flagIconName: String {
        switch self {
        case .high:   return "flag.fill"
        case .medium: return "flag.fill"
        case .low:    return "flag"
        }
    }
}

// MARK: - CompletionStatus 表示用拡張（Viewレイヤー専用）

private extension CompletionStatus {
    /// 3段階それぞれの SF Symbol 名。
    var symbolName: String {
        switch self {
        case .none:     return "circle"
        case .partial:  return "circle.lefthalf.fill"   // ◐
        case .complete: return "checkmark.circle.fill"  // ✓
        }
    }

    /// 3段階それぞれのアイコン色。
    var symbolColor: Color {
        switch self {
        case .none:     return .secondary
        case .partial:  return .orange
        case .complete: return .green
        }
    }
}

// MARK: - ContentView

struct ContentView: View {

    @StateObject private var viewModel = TodoViewModel()

    /// 入力欄の文字列。
    @State private var newTodoTitle: String = ""

    /// 追加時に選択する優先度（前回選択を保持）。
    @State private var selectedPriority: Priority = .medium

    @FocusState private var isInputFocused: Bool

    /// 現在展開中の親TODOのID集合。
    @State private var expandedIDs: Set<UUID> = []

    private var isInputEmpty: Bool {
        newTodoTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func makeExpansionBinding(for id: UUID) -> Binding<Bool> {
        Binding(
            get: { expandedIDs.contains(id) },
            set: { if $0 { expandedIDs.insert(id) } else { expandedIDs.remove(id) } }
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isEmpty {
                    emptyStateView
                } else {
                    todoListView
                }
                inputBar
            }
            .navigationTitle("SimpleTodo")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("未完了 \(viewModel.remainingCount) / 全 \(viewModel.totalCount)")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.snappy, value: viewModel.totalCount)
                        .animation(.snappy, value: viewModel.remainingCount)
                }
            }
        }
    }

    // MARK: - TODO一覧

    private var todoListView: some View {
        List {
            ForEach(viewModel.items) { item in
                TodoDisclosureRow(
                    viewModel: viewModel,
                    item: item,
                    isExpanded: makeExpansionBinding(for: item.id)
                )
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation { viewModel.delete(item) }
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
            }
            .onDelete { offsets in
                withAnimation { viewModel.delete(at: offsets) }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.snappy, value: viewModel.items)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("まだTODOがありません", systemImage: "checklist")
        } description: {
            Text("下の入力欄から最初のTODOを追加しましょう")
        }
        .frame(maxHeight: .infinity)
        .transition(.opacity)
    }

    // MARK: - 入力バー

    private var inputBar: some View {
        HStack(spacing: 8) {
            // テキスト入力欄。
            HStack(spacing: 8) {
                Image(systemName: "pencil.line")
                    .foregroundStyle(.secondary)
                    .font(.body)

                TextField("新しいTODOを入力", text: $newTodoTitle)
                    .focused($isInputFocused)
                    .submitLabel(.done)
                    .onSubmit(addTodo)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))

            // 優先度 Menu。タップで HIGH / MED / LOW を選択できます。
            Menu {
                ForEach(Priority.allCases, id: \.self) { p in
                    Button {
                        withAnimation(.snappy) { selectedPriority = p }
                    } label: {
                        Label(
                            "\(p.localizedLabel)（\(p.displayLabel)）",
                            systemImage: selectedPriority == p ? "checkmark" : p.flagIconName
                        )
                    }
                }
            } label: {
                Image(systemName: selectedPriority.flagIconName)
                    .font(.title2)
                    .foregroundStyle(selectedPriority.tintColor)
                    .frame(width: 34, height: 34)
                    // 優先度が変わるときにアイコンをふわっと差し替えます。
                    .contentTransition(.symbolEffect(.replace))
                    .animation(.snappy, value: selectedPriority)
            }
            .accessibilityLabel("優先度を選択: \(selectedPriority.localizedLabel)")

            // 追加ボタン。
            Button(action: addTodo) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(isInputEmpty ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tint))
                    .symbolRenderingMode(.hierarchical)
                    .scaleEffect(isInputEmpty ? 0.92 : 1.0)
            }
            .buttonStyle(.plain)
            .disabled(isInputEmpty)
            .animation(.snappy, value: isInputEmpty)
            .accessibilityLabel("TODOを追加")
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }

    // MARK: - アクション

    private func addTodo() {
        guard !isInputEmpty else { return }
        withAnimation(.snappy) {
            viewModel.addTodo(title: newTodoTitle, priority: selectedPriority)
            newTodoTitle = ""
        }
        isInputFocused = false
    }
}

// MARK: - TodoDisclosureRow

/// 親TODO1件分の行。DisclosureGroup でサブタスクを展開します。
private struct TodoDisclosureRow: View {

    @ObservedObject var viewModel: TodoViewModel
    let item: TodoItem
    @Binding var isExpanded: Bool

    @State private var subtaskDraft: String = ""
    @FocusState private var isSubtaskFocused: Bool

    private var isDraftEmpty: Bool {
        subtaskDraft.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            // サブタスク一覧。
            ForEach(item.subtasks) { subtask in
                SubtaskRow(subtask: subtask) {
                    withAnimation(.snappy) {
                        viewModel.toggleSubtask(subtask, in: item)
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.deleteSubtask(subtask, from: item)
                        }
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
            }

            // サブタスク追加欄。
            addSubtaskRow
        } label: {
            parentLabel
        }
        // 優先度をロングプレスで変更できるコンテキストメニュー。
        .contextMenu {
            Menu("優先度を変更") {
                ForEach(Priority.allCases, id: \.self) { p in
                    Button {
                        withAnimation(.snappy) {
                            viewModel.setPriority(p, for: item)
                        }
                    } label: {
                        if item.priority == p {
                            Label("\(p.localizedLabel)（\(p.displayLabel)）", systemImage: "checkmark")
                        } else {
                            Text("\(p.localizedLabel)（\(p.displayLabel)）")
                        }
                    }
                }
            }
        }
        .animation(.snappy, value: item.subtasks)
    }

    // MARK: - 親ラベル

    private var parentLabel: some View {
        HStack(spacing: 12) {
            // 3段階の完了アイコン。タップで完了を切り替えます。
            Button {
                withAnimation(.snappy) {
                    viewModel.toggleCompletion(for: item)
                }
            } label: {
                let status = item.completionStatus
                Image(systemName: status.symbolName)
                    .foregroundStyle(status.symbolColor)
                    .font(.title2)
                    // 状態変化をなめらかにアニメーション。
                    .symbolEffect(.bounce, value: status)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel({
                switch item.completionStatus {
                case .none:     return "未完了にする"
                case .partial:  return "完了にする"
                case .complete: return "未完了に戻す"
                }
            }())

            // 親タイトル。完了済みは取り消し線 + グレー。一部完了は通常表示。
            Text(item.title)
                .strikethrough(item.completionStatus == .complete, color: .secondary)
                .foregroundStyle(item.completionStatus == .complete ? .secondary : .primary)

            Spacer()

            // 優先度バッジ。
            PriorityBadge(priority: item.priority)

            // サブタスクがある場合の進捗「n/m」。
            if item.hasSubtasks {
                Text("\(item.completedSubtaskCount)/\(item.subtasks.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.snappy, value: item.completedSubtaskCount)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - サブタスク追加欄

    private var addSubtaskRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.turn.down.right")
                .foregroundStyle(.secondary)
                .font(.caption)

            TextField("サブタスクを追加", text: $subtaskDraft)
                .focused($isSubtaskFocused)
                .submitLabel(.done)
                .onSubmit(addSubtask)

            Button(action: addSubtask) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(isDraftEmpty ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tint))
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .disabled(isDraftEmpty)
            .accessibilityLabel("サブタスクを追加")
        }
        .padding(.leading, 8)
    }

    private func addSubtask() {
        guard !isDraftEmpty else { return }
        withAnimation(.snappy) {
            viewModel.addSubtask(to: item, title: subtaskDraft)
            subtaskDraft = ""
        }
    }
}

// MARK: - PriorityBadge

/// 優先度を示す小さなカプセルバッジ。
private struct PriorityBadge: View {
    let priority: Priority

    var body: some View {
        Text(priority.displayLabel)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(priority.tintColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            // 背景は優先度色の薄い塗り。
            .background(priority.tintColor.opacity(0.12), in: Capsule())
            // 優先度が切り替わるときにフェードで差し替えます。
            .contentTransition(.symbolEffect(.replace))
            .animation(.snappy, value: priority)
    }
}

// MARK: - SubtaskRow

/// サブタスク1件分の行（変更なし）。
private struct SubtaskRow: View {
    let subtask: SubTask
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(subtask.isCompleted ? .green : .secondary)
                .font(.body)
                .symbolEffect(.bounce, value: subtask.isCompleted)
                .contentTransition(.symbolEffect(.replace))

            Text(subtask.title)
                .font(.callout)
                .strikethrough(subtask.isCompleted, color: .secondary)
                .foregroundStyle(subtask.isCompleted ? .secondary : .primary)

            Spacer()
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(subtask.isCompleted ? "完了" : "未完了")
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
