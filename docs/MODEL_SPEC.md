# モデル設計書（Model Design Document）

## 1. ER図
<img width="843" alt="Image" src="https://github.com/user-attachments/assets/580cb647-2573-4b45-8f1c-8b176398b74c" />

## 2. テーブル定義
### `users`

> ユーザー情報を管理するテーブルです。

| カラム名 | 型 | 制約 | 説明 |
| --- | --- | --- | --- |
| id | bigint | Primary Key | ユーザーID（自動採番） |
| first_name | varchar | not null | 名 |
| last_name | varchar | not null | 姓 |
| email | varchar | not null, unique | メールアドレス（ユニーク） |
| password_digest | varchar | not null | ハッシュ化されたパスワード |
| created_at | datetime | not null | 作成日時 |
| updated_at | datetime | not null | 更新日時 |
- リレーション:
    - users (1) → (N) tasks
    - users (1) → (N) users_workspaces
    - users (1) → (0..N) progress_summaries

---

### `workspaces`

> 複数のユーザーが所属する作業スペース（プロジェクト）を管理するテーブルです。
> 

| カラム名 | 型 | 制約 | 説明 |
| --- | --- | --- | --- |
| id | bigint | Primary Key | ワークスペースID |
| title | varchar | not null | ワークスペース名 |
| created_at | datetime | not null | 作成日時 |
| updated_at | datetime | not null | 更新日時 |
- リレーション:
    - workspaces (1) → (N) tasks
    - workspaces (1) → (N) users_workspaces
    - workspaces (1) → (N) progress_summaries

---

### `users_workspaces`

> ユーザーとワークスペースの多対多関係をつなぐ中間テーブルです。
> 

| カラム名 | 型 | 制約 | 説明 |
| --- | --- | --- | --- |
| id | bigint | Primary Key | ID |
| user_id | bigint | Foreign Key, not null | ユーザーID（usersテーブル参照） |
| workspace_id | bigint | Foreign Key, not null | ワークスペースID（workspaces参照） |
| created_at | datetime | not null | 作成日時 |
| updated_at | datetime | not null | 更新日時 |
- リレーション:
    - users ↔ workspaces（多対多）

---

### `tasks`

> 各ワークスペースにおける個別のタスクを管理するテーブルです。

| カラム名 | 型 | 制約 | 説明 |
| --- | --- | --- | --- |
| id | bigint | Primary Key | タスクID |
| title | varchar | not null | タイトル |
| status | varchar | not null | ステータス（enum） |
| category | varchar | not null | カテゴリ（enum） |
| user_id | bigint | Foreign Key, not null | ユーザーID（users参照） |
| workspace_id | bigint | Foreign Key, not null | ワークスペースID（workspaces参照） |
| created_at | datetime | not null | 作成日時 |
| updated_at | datetime | not null | 更新日時 |
- リレーション:
    - tasks (N) → (1) users
    - tasks (N) → (1) workspaces

#### enum: status
> タスクの進行状況

| 内部値 | 表示名 |
| --- | --- |
| not_started | 未着手 |
| in_progress | 進行中 |
| completed | 完了 |

#### enum: category
> タスクの分類

| 内部値 | 表示名 |
| --- | --- |
| planning | 企画 |
| design | デザイン |
| frontend | フロントエンド |
| backend | バックエンド |
| test | テスト |

---

### `progress_summaries`

> タスクの進捗率を集計した結果を記録するテーブルです。

| カラム名 | 型 | 制約 | 説明 |
| --- | --- | --- | --- |
| id | bigint | Primary Key | ID |
| workspace_id | bigint | Foreign Key, not null | ワークスペースID（workspaces参照） |
| user_id | bigint | Foreign Key, nullable | ユーザーID（users参照）※全体集計時はnull |
| total | integer | not null | タスク総数 |
| done | integer | not null | 完了タスク数 |
| percent | integer | not null | 進捗率（%） |
| aggregated_at | datetime | not null | 集計日時 |
| aggregation_id | uuid | not null | 集計グループ識別子（UUID） |
| created_at | datetime | not null | 作成日時 |
| updated_at | datetime | not null | 更新日時 |
- リレーション:
    - progress_summaries (N) → (1) workspaces
    - progress_summaries (N) → (0..1) users