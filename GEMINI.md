# GEMINI.md

このファイルは、Gemini CLI がこのリポジトリで作業する際の手順とコンテキストを提供します。

## プロジェクト概要
**Dokoiku** は、SwiftUI と SwiftData を使用した iOS アプリケーションです。
- **主な技術:** Swift, SwiftUI, SwiftData
- **アーキテクチャ:** SwiftUI ベースの宣言的 UI と SwiftData による永続化。サードパーティ製ライブラリへの依存はありません。

## ビルドと実行
通常、Xcode でプロジェクトを開いて開発を行います。

```sh
open Dokoiku.xcodeproj
```

コマンドラインからのビルド:
```sh
xcodebuild -project Dokoiku.xcodeproj -scheme Dokoiku -configuration Debug build
```

テストの実行（テストターゲット作成後）:
```sh
xcodebuild test -project Dokoiku.xcodeproj -scheme Dokoiku -destination 'platform=iOS Simulator,name=iPhone 16'
```

スキームとターゲットの確認:
```sh
xcodebuild -list -project Dokoiku.xcodeproj
```

## 開発コンテキスト
### ディレクトリ構造
- `Dokoiku/`: メインのソースコード
  - `DokoikuApp.swift`: アプリのエントリポイント。SwiftData の `ModelContainer` を構成します。
  - `ContentView.swift`: 主要な UI（リスト表示、追加、削除）。
  - `Item.swift`: SwiftData モデルクラス。
- `Dokoiku.xcodeproj/`: Xcode プロジェクトファイル。

### コーディング規約
- インデントはスペース4つ。
- 型名は `UpperCamelCase`、プロパティやメソッドは `lowerCamelCase`。
- View は 1画面または 1つの再利用可能なコンポーネント単位で定義。
- ファイル内限定の動作には `private` ヘルパーを使用。
- UI の変更には SwiftUI プレビューを活用。SwiftData が必要な場合は `.modelContainer(for: Item.self, inMemory: true)` を使用。

### テスト方針
- 現在、テストターゲットは存在しません。大規模なロジックを導入する前に `DokoikuTests` ターゲットを追加してください。
- テストファイル名は対象の型名に対応させる（例: `ItemTests.swift`）。

### コミットメッセージ
- 日本語または英語の簡潔な命令形（例: `アイテム削除 UI を追加`, `Add item deletion UI`）。
- 既存のプロジェクト方針に従い、絵文字の使用ルールがある場合はそれに従うこと。

## 言語ルール
- **常に日本語で回答してください。**
