# Team Task Manager
本リポジトリは、DataXエンジニア選考課題  
「簡易SaaS型タスク共有ツールの開発＋設計書・テスト作成」に対する成果物となります。

## 📌 概要
Team Task Managerは、複数のワークスペースにおいてタスクの登録・共有・進捗確認を行える、シンプルなSaaS型のタスク管理ツールです。

## 🛠 使用技術スタック

| 区分         | 使用技術                            |
|--------------|-------------------------------------|
| バックエンド | Ruby on Rails（APIモード）         |
| フロントエンド | Vue.js 3 / Vite / Pug              |
| 状態管理     | Pinia                               |
| データベース | SQLite3                             |
| 認証方式     | JWT               |
| バッチ処理   | Rakeタスク + crontab（進捗率集計） |
| テスト       | RSpec                               |

## 🗂 ディレクトリ構成

```bash
/backend       # Rails API モード
/frontend      # Vue.js SPA（Vite + Pug）
/docs          # 設計ドキュメント
```

## 🔐 主な機能

- ユーザー認証（新規登録 / ログイン / ログアウト）
- ワークスペースの作成・参加
- タスクのCRUD
- タスクのフィルタリング（カテゴリ / ステータス / 担当者）
- 進捗率の可視化（個人別・ワークスペース全体）
- バッチ処理による進捗率の自動集計（平日9:00〜20:00、5分間隔）

## 🚀 ローカル環境での起動方法

### 1. バックエンド（Rails）

```bash
cd backend
bundle install
rails db:setup     # DB初期化およびシードデータ投入
rails server
```

### 2. フロントエンド（Vue）

```bash
cd frontend
npm install
npm run dev
```

## 🔑 環境変数の設定

JWT認証のため、`.env` ファイルを作成し、以下の内容を記述してください。

```env
JWT_SECRET_KEY=your_secret_key_here
```

※ `.env` は `.gitignore` によりGitには含まれません。

## 🔁 進捗率の自動集計

進捗率データは、Rakeタスクおよびcrontabを使用して、  
**平日9:00〜20:00の間、5分ごとに自動的に集計・更新**されます。

```bash
# crontab -e に以下を追加してください（例）
*/5 9-20 * * 1-5 cd /your_project_path/backend && bundle exec rake progress:refresh
```

## 📄 設計ドキュメント（/docs）

以下のMarkdownファイルにて、日本語での設計資料を記述しております。

- `SCREEN_SPEC.md` : 画面仕様書（画面構成、入力項目、エラーメッセージ仕様など）
- `MODEL_SPEC.md` : モデル設計書（ER図、テーブル・カラム構成）
- `FEATURE_SPEC/01_API_ENDPOINTS.md` : APIエンドポイント仕様およびエラーフォーマット
- `FEATURE_SPEC/02_SCREEN_FLOW.md` : 画面ごとの処理フロー・バリデーション

## ✅ テスト実装

Rails側では、モデル・APIに対するユニットテストをRSpecにて実装しております。

### モデルバリデーションテスト（`/backend/spec/models/`）

- `User`
  - メールアドレスの形式、パスワードの長さ・強度（英字・数字・記号を含む）の検証
- `Workspace`
  - タイトルが必須であること、ユーザーとの関連付けの正常性
- `Task`
  - タイトルの必須チェック、ステータスに未定義の値を指定した場合の例外処理
- `ProgressSummary`
  - 進捗率（percent）が0〜100の範囲であること
  - user_idがnilである全体集計のケースでも有効であること

### APIエンドポイントテスト（`/backend/spec/requests/`）

- `POST /signup`
  - 正常なユーザー登録ができること（バリデーション通過時の成功レスポンス確認）
- `POST /login`
  - 正しいパスワードでログイン成功、誤ったパスワードで401エラーを返すこと
- `POST /workspaces`, `GET /workspaces`
  - 認証済みユーザーによるワークスペース作成・取得が可能なこと
- `POST /workspaces/:workspace_id/tasks`, `PATCH /.../tasks/:id`
  - タスクの新規登録・更新が適切に動作すること
- `GET /workspaces/:id/progress_summary`
  - 認証あり：集計結果取得成功
  - 認証なし：401 Unauthorized エラーが返されること

すべてのテストは以下のコマンドで実行可能です：
```bash
cd backend
bundle exec rspec
```

## 🎞 動作動画

| 機能 | 動画リンク |
|------|------------|
| 1. ユーザー登録・ログイン | [こちら](https://github.com/user-attachments/assets/4ee30376-9fc3-4256-9321-e64e7267aea3) |
| 2. サイドバー操作（一覧表示・作成・参加・ログアウト） | [こちら](https://github.com/user-attachments/assets/1b8c4415-5888-43e9-b25d-a1d8fc35f854) |
| 3. 進捗率の確認 | [こちら](https://github.com/user-attachments/assets/02f6a4b1-6870-4290-9f2c-0ae9aa392bc3) |
| 4. タスクの作成・編集・削除 | [こちら](https://github.com/user-attachments/assets/f172bdb5-0977-4aac-96ab-2a6f7233c4fb) |
| 5. タスク一覧 | [こちら](https://github.com/user-attachments/assets/7aef2ae3-efd6-434b-9fe7-709ddcad03d0) |
| 6. タスクフィルタ | [こちら](https://github.com/user-attachments/assets/84a88160-0fb5-47ad-a889-ac9dc7a43f38) |


## 🎞 動作動画
### 1. ユーザー登録・ログイン
https://github.com/user-attachments/assets/4ee30376-9fc3-4256-9321-e64e7267aea3

### 2. サイドバー操作（一覧表示・作成・参加・ログアウト）
https://github.com/user-attachments/assets/1b8c4415-5888-43e9-b25d-a1d8fc35f854

### 3. 進捗率の確認
https://github.com/user-attachments/assets/02f6a4b1-6870-4290-9f2c-0ae9aa392bc3

### 4. タスクの作成・編集・削除	
https://github.com/user-attachments/assets/f172bdb5-0977-4aac-96ab-2a6f7233c4fb

### 5. タスク一覧
https://github.com/user-attachments/assets/7aef2ae3-efd6-434b-9fe7-709ddcad03d0

### 6. タスクフィルタ
https://github.com/user-attachments/assets/84a88160-0fb5-47ad-a889-ac9dc7a43f38
