# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## プロジェクト概要

Habyは、Ruby on Rails 7.2.3で構築された薬・サプリメントの服用習慣を記録するWebアプリケーションです。

**技術スタック:**
- Ruby 3.3.6 / Rails 7.2.3
- PostgreSQL
- Hotwire (Turbo + Stimulus) - フロントエンドのインタラクティブ機能
- Tailwind CSS - スタイリング
- Devise - 認証
- esbuild - JavaScriptバンドル
- Docker - 開発環境

## 開発コマンド

```bash
# 初期セットアップ
./bin/setup

# 開発サーバー起動 (Foreman + Procfile.dev)
./bin/dev

# Dockerで起動する場合
docker compose up

# データベース操作
bin/rails db:migrate
bin/rails db:seed
bin/rails db:prepare

# テスト実行
bin/rails test              # ユニットテスト
bin/rails test:system       # システムテスト (Capybara/Selenium)
bin/rails db:test:prepare test test:system  # フルテストスイート (CI)

# Lint
bin/rubocop                 # Rubyスタイルチェック
bin/rubocop -a              # 自動修正

# セキュリティスキャン
bin/brakeman

# JavaScriptビルド
yarn build
```

## アーキテクチャ

### MVC構造 + Hotwire

サーバーサイドレンダリングのRailsビューに、TurboによるSPA風ナビゲーションとStimulusによるJavaScript動作を組み合わせた構成。

### コアドメインモデル

```
User (Devise)
  └── has_many :habits
  └── has_many :habit_logs

Habit
  └── belongs_to :user
  └── has_many :habit_logs
  └── 属性: name, detail, current_streak, longest_streak

HabitLog
  └── belongs_to :user, :habit
  └── 属性: log_date, is_taken (boolean), logged_at
  └── ユニーク制約: (user_id, habit_id, log_date)
```

### 主要ルート

- `/habits` - 習慣のCRUD操作
- `/habits/:id/today_log` - 今日の服用ログ更新
- `/habit_logs` - 服用履歴一覧
- `/calendar` - カレンダー表示
- `/todays_habits` - 今日の習慣ダッシュボード
- `/account` - アカウント管理 (名前、メール、パスワード)

### JavaScript構成

- エントリーポイント: `app/javascript/application.js`
- Stimulusコントローラー: `app/javascript/controllers/`
- カスタムモジュール: `app/javascript/hamburger_menu.js`
- ビルド出力: `app/assets/builds/`

## 設定

- **タイムゾーン:** Asia/Tokyo
- **デフォルトロケール:** 日本語 (`:ja`)
- **対応ロケール:** 日本語、英語
- **ロケールファイル:** `config/locales/ja.yml`, `config/locales/en.yml`

## CI/CD

GitHub Actionsがプルリクエストとmainへのプッシュ時に実行:
1. `scan_ruby` - Brakemanセキュリティスキャン
2. `lint` - Rubocop スタイルチェック
3. `test` - PostgreSQLとChromeを使用したフルテストスイート

## コーディング規約

- `rubocop-rails-omakase` スタイルプリセットを使用
- モデルバリデーション: 名前の必須・文字数制限、streakの非負値検証
- 服用ログのユニーク制約はデータベースレベルで強制
