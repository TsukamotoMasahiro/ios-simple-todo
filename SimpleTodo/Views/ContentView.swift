//
//  ContentView.swift
//  SimpleTodo
//
//  アプリのメイン画面（1画面構成）です。
//  TODOの一覧表示・追加・完了切り替え・削除・件数表示・Empty Stateを
//  ここでまとめて実装しています。
//

import SwiftUI

struct ContentView: View {

    /// ViewModelを監視します。`@StateObject` はこのViewが
    /// ViewModelの「持ち主」であることを表し、画面が再生成されても保持されます。
    @StateObject private var viewModel = TodoViewModel()

    /// 入力欄（TextField）に入っている文字列。
    @State private var newTodoTitle: String = ""

    /// キーボードの表示状態を管理するためのフォーカス。
    @FocusState private var isInputFocused: Bool

    /// 入力欄が空（空白のみ含む）かどうか。追加ボタンの有効/無効に使います。
    private var isInputEmpty: Bool {
        newTodoTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        // NavigationStackで画面上部にタイトルバーを表示します。
        NavigationStack {
            VStack(spacing: 0) {

                // 中央のメイン領域: TODOがあれば一覧、無ければEmpty State。
                if viewModel.isEmpty {
                    emptyStateView
                } else {
                    todoListView
                }

                // 画面下部のTODO追加エリア。
                inputBar
            }
            .navigationTitle("SimpleTodo")
            // ツールバーに件数を表示します（未完了 / 全体）。
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // HIG: 補助情報はセカンダリ色 + capsule背景で控えめに。
                    Text("未完了 \(viewModel.remainingCount) / 全 \(viewModel.totalCount)")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        // 件数が変わるときに数字をふわっと差し替えます。
                        .contentTransition(.numericText())
                        .animation(.snappy, value: viewModel.totalCount)
                        .animation(.snappy, value: viewModel.remainingCount)
                }
            }
        }
    }

    // MARK: - TODO一覧

    /// TODOが1件以上あるときに表示するリスト。
    private var todoListView: some View {
        List {
            ForEach(viewModel.items) { item in
                TodoRowView(item: item) {
                    // 行をタップしたら完了/未完了を切り替えます。
                    // withAnimationで取り消し線やアイコンの変化をなめらかにします。
                    withAnimation(.snappy) {
                        viewModel.toggleCompletion(for: item)
                    }
                }
                // 各行を右から左にスワイプすると削除ボタンが出ます。
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.delete(item)
                        }
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
            }
            // 編集モードや左スワイプでも削除できるようにします。
            .onDelete { offsets in
                withAnimation {
                    viewModel.delete(at: offsets)
                }
            }
        }
        .listStyle(.insetGrouped)
        // 行の追加・削除・並びの変化をアニメーションさせます。
        .animation(.snappy, value: viewModel.items)
    }

    // MARK: - Empty State

    /// TODOが0件のときに表示する案内。
    private var emptyStateView: some View {
        // iOS 17の標準的な空表示コンポーネント（HIG準拠の見た目）。
        ContentUnavailableView {
            Label("まだTODOがありません", systemImage: "checklist")
        } description: {
            Text("下の入力欄から最初のTODOを追加しましょう")
        }
        // 上下方向に広げて中央に配置します。
        .frame(maxHeight: .infinity)
        // 表示時にふわっとフェードインさせます。
        .transition(.opacity)
    }

    // MARK: - 入力バー

    /// 画面下部のTextField + 追加ボタン。
    private var inputBar: some View {
        HStack(spacing: 10) {
            // 入力欄。先頭にアイコンを添えてHIG風の体裁にします。
            HStack(spacing: 8) {
                Image(systemName: "pencil.line")
                    .foregroundStyle(.secondary)
                    .font(.body)

                TextField("新しいTODOを入力", text: $newTodoTitle)
                    .focused($isInputFocused)
                    .submitLabel(.done)
                    // キーボードの確定キーでも追加できるようにします。
                    .onSubmit(addTodo)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            // HIG: 入力欄は角丸の塗りで領域を分かりやすく。
            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))

            // 追加ボタン。Apple標準の塗りつぶし円アイコン。
            Button(action: addTodo) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 34))
                    // 無効時は薄く、有効時はアクセントカラーで強調。
                    .foregroundStyle(isInputEmpty ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tint))
                    .symbolRenderingMode(.hierarchical)
                    // 有効/無効の切り替え時に軽く拡大して気づきやすく。
                    .scaleEffect(isInputEmpty ? 0.92 : 1.0)
            }
            .buttonStyle(.plain)
            .disabled(isInputEmpty)
            .animation(.snappy, value: isInputEmpty)
            .accessibilityLabel("TODOを追加")
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        // 入力バーを区切るために上に薄い境界線を引きます。
        .background(.bar)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    // MARK: - アクション

    /// 入力中の文字列でTODOを追加し、入力欄をリセットします。
    private func addTodo() {
        guard !isInputEmpty else { return }
        // 追加と入力欄リセットをアニメーション付きで反映します。
        withAnimation(.snappy) {
            viewModel.addTodo(title: newTodoTitle)
            newTodoTitle = ""
        }
        isInputFocused = false
    }
}

/// TODO1件分の行を表すView。一覧から切り出して読みやすくしています。
private struct TodoRowView: View {

    /// 表示するTODO。
    let item: TodoItem

    /// 行がタップされたときに呼ばれるクロージャ（完了切り替え）。
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 完了/未完了を表すアイコン。SF Symbolsを使用。
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.isCompleted ? .green : .secondary)
                .font(.title2)
                // 完了状態が変わった瞬間にアイコンを弾ませる軽いアニメーション。
                .symbolEffect(.bounce, value: item.isCompleted)
                // 丸→チェックの差し替えをなめらかに見せます。
                .contentTransition(.symbolEffect(.replace))

            // TODOのタイトル。完了済みなら取り消し線とグレー表示にします。
            Text(item.title)
                .strikethrough(item.isCompleted, color: .secondary)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)

            Spacer()
        }
        .padding(.vertical, 4)
        // 行全体（余白を含む）をタップ可能にします。
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
        // VoiceOver: 行全体を1つのボタンとして読み上げ、状態も伝えます。
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(item.isCompleted ? "完了" : "未完了")
    }
}

// Xcodeプレビュー（実機やSimulatorを起動しなくても見た目を確認できます）。
#Preview {
    ContentView()
}
