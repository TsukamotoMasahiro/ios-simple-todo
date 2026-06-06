# Tsukamoto SimpleTodo

App Store リリースまでの流れを学習するための、最小構成の SwiftUI 製 TODO アプリです。
外部 API・ログイン・課金・クラウド同期は使わず、データは端末内（UserDefaults）にのみ保存します。

> **名称について**
> - **App Store 表示名 / App Store Connect 登録名**: `Tsukamoto SimpleTodo`（端末ホーム画面やストアに表示される名前）
> - **Xcode プロジェクト / ターゲット / フォルダー名**: `SimpleTodo`（内部的な名前。変更不要）
>
> App Store Connect でアプリ名 `SimpleTodo` が他者に使用済みで登録に失敗したため、
> 表示名・登録名を重複しにくい `Tsukamoto SimpleTodo` に変更しています。
> Bundle Identifier（`com.tsukamoto.simpletodo`）は変更していません。

---

## プロジェクト概要

- **App Store 表示名**: `Tsukamoto SimpleTodo`（`INFOPLIST_KEY_CFBundleDisplayName`）
- **プロジェクト/ターゲット名**: `SimpleTodo`（内部名）
- **Bundle Identifier**: `com.tsukamoto.simpletodo`
- **UI**: SwiftUI（1 画面構成、`NavigationStack`）
- **対応 OS**: iOS 17.0 以上
- **アーキテクチャ**: MVVM
- **保存方式**: UserDefaults + Codable（JSON 化して端末に保存）
- **外部依存**: なし（Swift Package Manager / CocoaPods 等は不使用）

### 実装している機能

- TODO 一覧の表示（`List`）
- TODO の追加（下部の入力欄 + 追加ボタン、確定キーでも追加可）
- 完了 / 未完了の切り替え（行タップ、または完了アイコン）
- TODO の削除（右スワイプ、または編集での削除）
- 件数表示（画面右上に「未完了 ◯ / 全 ◯」）
- Empty State（0 件のときの案内表示）
- アプリを終了してもデータが残る（永続化）

### ファイル構成

```text
ios-simple-todo/
├── SimpleTodo/
│   ├── SimpleTodoApp.swift        # アプリの入口（@main）
│   ├── Models/
│   │   └── TodoItem.swift         # TODO 1件分のデータモデル
│   ├── ViewModels/
│   │   └── TodoViewModel.swift    # 追加/切り替え/削除などのロジック（MVVMのVM）
│   ├── Views/
│   │   └── ContentView.swift      # メイン画面（一覧・入力・Empty State）
│   ├── Utilities/
│   │   └── TodoStorage.swift      # UserDefaults への保存・読み込み
│   └── Assets.xcassets            # アイコン・アクセントカラー
├── SimpleTodo.xcodeproj           # Xcode プロジェクト
└── README.md
```

> **MVVM の役割分担**
> - **Model** (`TodoItem`): データの形。
> - **ViewModel** (`TodoViewModel`): 追加・切り替え・削除などの操作と状態管理。
> - **View** (`ContentView`): 表示に専念。ユーザー操作を ViewModel に渡すだけ。
> - **Storage** (`TodoStorage`): 保存の仕組みを ViewModel から分離。

---

## 必要環境

- macOS（Xcode が動作するバージョン）
- **Xcode 16 以上**（このプロジェクトは Xcode 16 のプロジェクト形式を使用）
- iOS 17.0 以上の Simulator または実機
- 実機で動かす場合は Apple ID（無料でも可。詳細は後述）

---

## Xcode で開く方法

ターミナルから:

```bash
open ios-simple-todo/SimpleTodo.xcodeproj
```

または Finder で `SimpleTodo.xcodeproj` をダブルクリックします。

> Swift ファイルは「フォルダー同期グループ（file system synchronized group）」として
> 取り込まれるため、`SimpleTodo/` 配下にファイルを追加・削除すると Xcode に自動で反映されます。

---

## Simulator で実行する方法

1. Xcode 上部のスキーム選択（実行ボタンの右）で **SimpleTodo** を選びます。
2. その隣のデバイス選択で、任意の iPhone Simulator（例: iPhone 15）を選びます。
3. **▶︎（Run）ボタン** を押す（ショートカット: `Cmd + R`）。
4. Simulator が起動し、アプリが立ち上がります。

> 初回は Simulator のダウンロードを求められることがあります。
> その場合は Xcode の指示に従ってインストールしてください。

---

## 実機（iPhone 実機）で実行する方法

1. iPhone を Mac に USB ケーブルで接続します。
2. iPhone 側で「このコンピュータを信頼しますか？」と出たら **信頼** を選びます。
3. Xcode のデバイス選択で、接続した iPhone を選びます。
4. **Signing & Capabilities** の設定（次節参照）で Team を設定します。
   - 無料の Apple ID でも個人テストは可能です（7 日間で署名の再取得が必要）。
5. **▶︎（Run）** を押します。
6. 初回は iPhone 側で開発者を信頼する操作が必要です:
   `設定 → 一般 → VPN とデバイス管理 → （あなたの Apple ID）→ 信頼`

---

## App Store 公開練習で次にやること

学習目的でのリリースフローの大まかな順序です。

### 1. Apple Developer Program の確認
- 実機テストだけなら無料の Apple ID で可能。
- **App Store 公開 / TestFlight 配布には有料の Apple Developer Program（年額）が必要**。
- <https://developer.apple.com/programs/> から登録状況を確認します。

### 2. Signing & Capabilities 設定
- Xcode でプロジェクト → **TARGETS: SimpleTodo → Signing & Capabilities** を開く。
- **Automatically manage signing** にチェック。
- **Team** に自分の Apple ID / Developer アカウントを選択。
- **Bundle Identifier** が `com.tsukamoto.simpletodo`（または世界で一意な値）になっていることを確認。

### 3. Archive 作成
- デバイス選択を **Any iOS Device (arm64)** にする（Simulator では Archive できません）。
- メニュー **Product → Archive** を実行。
- 完了すると **Organizer** ウィンドウにアーカイブが表示されます。

### 4. App Store Connect 登録
- <https://appstoreconnect.apple.com/> でアプリのレコードを新規作成。
- **アプリ名（App Name）には `Tsukamoto SimpleTodo` を入力**（`SimpleTodo` は他者が使用済みで登録に失敗するため）。
- アプリ名・Bundle ID・SKU・カテゴリ・説明文・スクリーンショット等を登録。

### 5. TestFlight 配布
- Organizer から **Distribute App → App Store Connect → Upload** でビルドをアップロード。
- App Store Connect の **TestFlight** タブで、内部 / 外部テスターにビルドを配布。
- テスターは TestFlight アプリでインストールして動作確認できます。

### 6. App Review 提出
- App Store Connect で配布用ビルドを選択し、必要情報（プライバシー、年齢制限など）を入力。
- **「審査へ提出（Submit for Review）」** を実行。
- Apple の審査を通過すると公開（または手動リリース）できます。

> 補足: 本アプリは個人情報を収集しないため、プライバシー周りはシンプルですが、
> App Store Connect の「App のプライバシー」設問には「データを収集しない」を正しく申告してください。

---

## App Store 提出準備チェックリスト

提出前に確認する項目です。✅ は本リポジトリで設定済み、⬜️ は人間（あなた）が用意・操作する項目です。

### プロジェクト側（設定済み）

- ✅ **App Icon**: `Assets.xcassets/AppIcon.appiconset/AppIcon.png`（1024×1024 / PNG / 不透明 / アルファなし / 角丸なしの正方形）
- ✅ **Contents.json** が `AppIcon.png` を参照
- ✅ **Bundle Identifier**: `com.tsukamoto.simpletodo`
- ✅ **Display Name**: `Tsukamoto SimpleTodo`（`INFOPLIST_KEY_CFBundleDisplayName`）
- ✅ **App Store Connect 登録名**: `Tsukamoto SimpleTodo`（`SimpleTodo` は他者が使用済みのため変更）
- ✅ **Deployment Target**: iOS 17.0
- ✅ **バージョン**: `MARKETING_VERSION = 1.0` / `CURRENT_PROJECT_VERSION = 1`
- ✅ **暗号化輸出コンプライアンス**: `ITSAppUsesNonExemptEncryption = NO` を設定済み（標準的なHTTPS等も使わない無通信アプリのため、TestFlightで毎回問われる暗号化の質問を回避）

### 人間が用意・操作する項目

- ⬜️ **Apple Developer Program**（有料・年額）への加入（App Store / TestFlight 配布に必須）
- ⬜️ **Signing & Capabilities** で Team を選択（自動署名）
- ⬜️ **スクリーンショット**（後述の手順で作成）
- ⬜️ **App Store Connect** でのアプリ情報入力（後述）
- ⬜️ **プライバシーポリシー URL**（後述）
- ⬜️ **Archive → アップロード → 審査提出**

---

## App Icon の確認方法

1. Xcode で `Assets.xcassets` を開き、左の一覧から **AppIcon** を選択。
2. 1024×1024 のスロットにブルーのチェックリストアイコンが表示されていれば OK。
3. ビルドして Simulator / 実機のホーム画面にアイコンが出ることを確認。
4. （任意）ターミナルで画像の素性を確認:
   ```bash
   sips -g pixelWidth -g pixelHeight -g hasAlpha SimpleTodo/Assets.xcassets/AppIcon.appiconset/AppIcon.png
   # 期待値: 1024 / 1024 / hasAlpha: no
   ```

> 注意: App Store のアイコンは **アルファ（透明）チャンネルを含めてはいけません**。本リポジトリのアイコンはアルファなしで生成済みです。差し替える場合も「不透明・正方形・角丸なし・1024×1024・PNG」を守ってください（角丸は iOS が自動で付けます）。

---

## スクリーンショット作成手順

App Store Connect では、指定サイズのスクリーンショットが最低 1 枚必要です（iPhone 6.9"/6.7" など）。

1. Xcode でアプリを **Simulator** で実行（例: iPhone 15 Pro Max などの大画面）。
2. TODO をいくつか追加し、見栄えの良い状態にする（完了・未完了が混ざると分かりやすい）。
3. Simulator メニュー **File → Save Screen**（または `Cmd + S`）で画像を保存。
4. 必要なら別の端末サイズでも撮影（App Store Connect が要求するサイズに合わせる）。
5. 保存した PNG を App Store Connect の各サイズ欄にアップロード。

> ヒント: 最低限は最大サイズの iPhone 1 機種ぶんがあれば提出可能なことが多いです（要件は提出時に App Store Connect が表示します）。

### App Store提出用アセット

撮影済みのスクリーンショットは、プロジェクト直下の `appstore-assets/` フォルダーに整理しています。
これらを App Store Connect の各サイズ欄にアップロードします。

```text
appstore-assets/
├── screenshot-01-home.png       # TODO一覧（未完了が並んだ状態）
├── screenshot-02-completed.png  # 完了済みTODO（緑チェック + 取り消し線）
└── screenshot-03-empty.png      # Empty State（TODOが0件の状態）
```

> 補足: これらは以前 `SimpleTodo/Assets.xcassets/` 配下に誤って置かれていた Simulator スクリーンショットを、
> `appstore-assets/` に移動・リネームしたものです。アプリのビルドには含まれません（提出時の素材専用）。

---

## App Store Connect で必要になる主な項目

<https://appstoreconnect.apple.com/> でアプリを新規作成し、以下を登録します。

- アプリ名（`Tsukamoto SimpleTodo`）／サブタイトル（任意）
- プライマリ言語・カテゴリ（例: 仕事効率化 / ユーティリティ）
- Bundle ID（`com.tsukamoto.simpletodo`）・SKU（任意の管理用文字列）
- アプリの説明文・キーワード・サポートURL
- **プライバシーポリシー URL**（下記参照）
- スクリーンショット（上記手順で作成）
- 年齢制限（コンテンツレーティング）の設問回答
- **App のプライバシー（App Privacy）** の設問回答（下記参照）
- 価格（無料 / 有料）

---

## プライバシーポリシー URL について

- App Store 提出では、多くの場合 **プライバシーポリシーの URL が必須** です（無料・無通信アプリでも入力欄があります）。
- 公開できる URL（GitHub Pages、Notion 公開ページ、自分のサイト等）に簡単なプライバシーポリシーを掲載し、その URL を登録してください。
- 本アプリは個人データを収集・送信しないため、ポリシー本文は「当アプリは利用者の情報を収集・送信しません。データは端末内にのみ保存されます。」といった簡潔な内容で構いません（最終的な文面は自己責任でご確認ください）。

---

## このアプリのデータ取り扱い（App Privacy の整理）

**事実ベースの整理:**

- 外部 API・サーバー通信は **なし**
- ログイン・アカウント機能は **なし**
- 広告 SDK・解析 SDK は **なし**
- 課金（App内課金）は **なし**
- データ保存は **端末内の UserDefaults のみ**（TODO のテキストと完了状態）。クラウド同期なし。

この実装内容であれば、App Store Connect の **App Privacy** は基本的に **「データを収集していません（Data Not Collected）」** と整理できる可能性が高いです。

> ⚠️ ただし最終回答は **実装内容に基づいてあなた自身が確認・申告**してください。
> 今後、解析ツール・クラッシュレポート SDK・広告・クラウド同期などを **1つでも追加した場合**は「データを収集しない」では**なくなる**点に注意してください。
> Apple の定義では「第三者へ送信される」かどうかが鍵で、端末内にのみ保存され外部送信されないデータは通常「収集」に該当しません。

---

## サポート / プライバシーポリシーページ（GitHub Pages 公開）

App Store Connect では **Support URL** と **Privacy Policy URL** の入力が必要です。
本リポジトリの `docs/` フォルダーに、そのまま公開できる静的 HTML を用意しています。

```text
ios-simple-todo/
└── docs/
    ├── index.html     # トップページ（概要 + 各ページへのリンク）
    ├── support.html   # サポートページ（FAQ・問い合わせ先メール）
    └── privacy.html   # プライバシーポリシー（日本語）
```

- 外部 CSS / 外部 JS / 外部通信は **一切なし**（CSS は各 HTML 内にインライン記述）。
- スマホでも読みやすいレスポンシブ対応（`viewport` 指定 + 可変幅レイアウト）。
- 問い合わせ先メール: `masahiri.thukamoto@gmail.com`

### GitHub Pages 公開手順

1. このプロジェクトを GitHub のリポジトリ（例: `ios-simple-todo`）に push する。
   ```bash
   git add .
   git commit -m "Add support and privacy pages"
   git push origin main
   ```
2. GitHub の対象リポジトリで **Settings** を開く。
3. 左メニューの **Pages** を選択。
4. **Source** を **Deploy from a branch** にする。
5. **Branch** を **main**、**Folder** を **/docs** に設定して **Save**。
6. 数分待つと、`https://<ユーザー名>.github.io/<リポジトリ名>/` で公開される。

### 公開後に使う URL 例

GitHub ユーザー名が `TsukamotoMasahiro`、リポジトリ名が `ios-simple-todo` の場合:

- トップ: `https://tsukamotomasahiro.github.io/ios-simple-todo/`
- **Support URL**: `https://tsukamotomasahiro.github.io/ios-simple-todo/support.html`
- **Privacy Policy URL**: `https://tsukamotomasahiro.github.io/ios-simple-todo/privacy.html`

> 注意: 実際の URL は **GitHub ユーザー名 / リポジトリ名 / Pages の設定** によって変わります。
> 公開後、ブラウザで各ページが表示されることを確認してから App Store Connect に登録してください。

### App Store Connect への入力

App Store Connect の対象アプリ → **App 情報 / バージョン情報** で以下を入力します。

| 項目 | 入力する URL |
|---|---|
| Support URL | `https://tsukamotomasahiro.github.io/ios-simple-todo/support.html` |
| Privacy Policy URL | `https://tsukamotomasahiro.github.io/ios-simple-todo/privacy.html` |

---

## 補足・既知の制限（学習用のため）

- データは UserDefaults に保存しており、大量データには不向きです（学習用途では十分）。
- アプリアイコンは `Assets.xcassets/AppIcon.appiconset/AppIcon.png`（1024×1024・不透明・正方形）を配置済みです。
- 並び替え機能やカテゴリ分けはありません（最小構成のため）。
