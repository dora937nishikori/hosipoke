# アーキテクチャ

ほしポケは、画面・状態管理・データアクセスを分けた Flutter アプリです。

小規模な MVP ですが、将来の永続化方式変更やテスト追加に備え、Repository を境界にして実装しています。

## レイヤー構成

```text
screens / widgets
  ↓
PocketStore
  ↓
WishRepository
  ↓
SqfliteWishRepository
  ↓
SQLite
```

## 各層の責務

### UI 層

`screens` と `widgets` は表示とユーザー操作を担当します。

- `PocketView`
  - 保存済みアイテム一覧を表示します。
  - 追加ボタンやアイテム選択イベントを上位に渡します。
- `CameraPickerView`
  - カメラ撮影とギャラリー選択を担当します。
- `SaveItemView`
  - 新規アイテムのメモ・優先度入力を担当します。
- `ItemDetailView`
  - 既存アイテムの更新・削除操作を担当します。
- `ItemCard` / `PriorityPicker`
  - 再利用可能な表示部品を担当します。

UI 層は SQLite を直接扱わず、状態更新は `PocketStore` に委譲します。

### State / ViewModel 層

`PocketStore` は `ChangeNotifier` を継承した状態管理クラスです。

- 初期データを読み込む
- 新規アイテムを追加する
- メモ・優先度を更新する
- アイテムを削除する
- 画像をアプリの永続ディレクトリへコピーする
- Repository 経由で永続化し、UI に通知する

UI から見たデータ操作の入口を `PocketStore` に集約することで、画面側の責務を軽くしています。

### Domain 層

Domain 層は、アプリの中心となる型を持ちます。

- `Wish`
  - 保存するアイテムを表します。
  - `id`、`note`、`createdAt`、`imagePath`、`priority`、`aspectRatio` を持ちます。
- `WishPriority`
  - 優先度を enum として表します。
- `WishRepository`
  - データアクセスの抽象インターフェースです。

`WishRepository` を抽象化しているため、UI と状態管理は SQLite の詳細に依存しません。

### Data 層

Data 層は Repository の具体実装を持ちます。

- `SqfliteWishRepository`
  - SQLite のテーブル作成、取得、保存、更新、削除を担当します。
- `InMemoryWishRepository`
  - メモリ上で動く Repository 実装です。
  - テストや将来の差し替え例として利用できます。

## データフロー

### 新規保存

1. ユーザーが `CameraPickerView` で写真を撮影、またはギャラリーから選択します。
2. `SaveItemView` でメモと優先度を入力します。
3. `PocketStore.add()` が呼ばれます。
4. 画像をアプリの永続ディレクトリにコピーします。
5. `Wish` を作成します。
6. `WishRepository.save()` を呼びます。
7. `SqfliteWishRepository` が SQLite に保存します。
8. `PocketStore` が一覧を再取得し、UI に通知します。

### 一覧表示

1. アプリ起動後に `PocketStore.loadInitial()` を呼びます。
2. `WishRepository.fetchAll()` で保存済みアイテムを取得します。
3. `PocketView` が `PocketStore.items` を購読して一覧表示します。

### 更新・削除

更新と削除も UI から直接 SQLite を触らず、`PocketStore` を経由します。

- 更新: `ItemDetailView` → `PocketStore.update()` → `WishRepository.update()`
- 削除: `ItemDetailView` → `PocketStore.delete()` → 画像ファイル削除 → `WishRepository.delete()`

## 設計上の意図

### Repository 抽象化

永続化方式を SQLite に固定せず、`WishRepository` のインターフェースを経由しています。

これにより、将来的に以下の変更がしやすくなります。

- ローカルDBからクラウド同期へ変更する
- テスト時に fake repository を差し込む
- UI を変えずに保存方式だけ差し替える

### テスト容易性

`MyApp` は Repository を外から差し込めるようにしています。

Widget test では本物の SQLite やカメラを起動せず、fake repository を使います。これにより、テスト環境でも安定して UI の表示確認ができます。

### 責務分離

画面側に保存処理やデータベース操作を直接書かず、`PocketStore` と Repository に処理を寄せています。

これにより、各層の責務を以下のように分けています。

- UI 層は表示とユーザー操作を扱う
- `PocketStore` は状態変更の入口を担当する
- Repository は保存・取得・更新・削除の境界を担当する
- Data 層は SQLite など具体的な保存方式を担当する
