# ほしポケ（欲しいものポケット）

ほしポケは、欲しいものを写真で記録し、メモと優先度を付けて管理する Flutter 製のモバイルアプリです。

撮影した写真や選択した画像を「ほしいもの」として保存し、あとから一覧で見返したり、メモや優先度を更新したりできます。

現在は開発中です。Android を中心に実装・検証しており、iOS 対応は今後の予定です。

## 主な機能

- カメラで欲しいものを撮影
- ギャラリーから画像を選択
- 写真、メモ、優先度を保存
- 保存したアイテムを一覧表示
- アイテム詳細でメモ・優先度を更新
- アイテム削除

## 対応プラットフォーム

- Android: 実装・検証中
- iOS: 今後対応予定

## 技術スタック

- Flutter / Dart
- Provider
- sqflite
- camera
- image_picker
- path_provider
- flutter_lints
- GitHub Actions

## プロジェクト構成

```text
lib/
  data/          Repository の具体実装
  domain/        アプリの中心となる型・Repository インターフェース
  presentation/  表示用の変換処理
  providers/     状態管理
  screens/       画面
  widgets/       再利用する UI 部品
test/
  domain/        domain 層のテスト
```

画面、状態管理、データアクセスを分け、UI から SQLite を直接扱わない構成にしています。

## データの扱い

写真、メモ、優先度は端末内に保存します。現時点では外部サーバーへの送信処理はありません。

## ローカル実行

Flutter SDK をセットアップしたうえで、以下を実行します。

```bash
flutter pub get
flutter run
```

Android 実機またはエミュレータでの動作確認を想定しています。

## 品質チェック

ローカルでは以下のコマンドで静的解析とテストを実行できます。

```bash
flutter analyze
flutter test
```

GitHub Actions では、push / pull request 時に以下を実行します。

```bash
flutter pub get
flutter analyze
flutter test
```
