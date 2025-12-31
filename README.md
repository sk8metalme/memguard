# memguard - macOS用メモリ監視デーモン

Linux の `earlyoom` に相当するmacOS用のメモリ監視ツールです。
システムの空きメモリが閾値以下になると、指定したプロセス(claude/node)を自動終了します。

## 機能

- 🔍 5秒ごとにシステムメモリを監視
- ⚠️ 空きメモリが10%以下で警告
- 🔪 claude/nodeプロセスを自動終了 (SIGTERM → SIGKILL)
- 📢 macOS通知センターに通知
- 📝 ログファイルに記録（自動ローテーション対応）
- 🚀 Mac起動時に自動実行
- ⚙️ 設定ファイルで簡単カスタマイズ
- 🎯 CLIコマンドで簡単操作

## インストール

```bash
# ダウンロードしたディレクトリで実行
chmod +x install-memguard.sh
./install-memguard.sh
```

インストール後、`~/bin` にPATHが通っていない場合は、以下を `~/.zshrc` に追加してください:
```bash
export PATH="$HOME/bin:$PATH"
```

## 使い方

### 基本コマンド

```bash
# 状態確認
memguard status

# メモリチェック（ワンショット）
memguard check

# 詳細なメモリチェック
memguard check --verbose

# ドライラン（実際にプロセスを終了せずテスト）
memguard check --dry-run

# 現在の設定を表示
memguard config

# ログをリアルタイム表示
memguard logs

# ヘルプ表示
memguard help
```

### デーモン制御

```bash
# 停止
memguard stop

# 起動
memguard start

# 再起動
memguard restart
```

### 設定変更

設定ファイル `~/.memguardrc` を編集:

```bash
# memguard 設定ファイル

# 空きメモリ閾値 (%)
THRESHOLD_PERCENT=10

# チェック間隔 (秒)
CHECK_INTERVAL=5

# 対象プロセス (正規表現)
TARGET_PROCESSES="claude|node"

# ログファイルのパス
LOG_FILE="$HOME/.memguard.log"

# ログファイルの最大サイズ (MB)
LOG_MAX_SIZE_MB=10

# 通知の有効/無効
NOTIFY_ENABLED=true
```

変更後はデーモンを再起動:

```bash
memguard restart
```

## コマンド一覧

| コマンド | 説明 |
|---------|------|
| `memguard start` | デーモンを起動 |
| `memguard stop` | デーモンを停止 |
| `memguard restart` | デーモンを再起動 |
| `memguard status` | 現在の状態を表示 |
| `memguard check` | メモリ状態をチェック（ワンショット） |
| `memguard check --verbose` | 詳細なメモリチェック |
| `memguard check --dry-run` | ドライラン（テスト実行） |
| `memguard config` | 現在の設定を表示 |
| `memguard logs` | ログをリアルタイム表示 |
| `memguard version` | バージョン表示 |
| `memguard help` | ヘルプ表示 |

## 使用例

### 状態確認

```bash
$ memguard status
memguard v1.1.0 - 実行中 (PID: 12345)
空きメモリ: 45% (7372MB / 16384MB)
対象プロセス: 7個
閾値: 10%
```

### メモリチェック

```bash
$ memguard check
空きメモリ: 45% (7372MB / 16384MB)
状態: OK (閾値10%を上回っています)

$ memguard check --verbose
空きメモリ: 8% (1310MB / 16384MB)
状態: WARNING (閾値10%以下)

対象プロセス:
  - node (PID: 12345) - Memory: 25.3%
  - node (PID: 12346) - Memory: 12.1%
  - claude (PID: 12347) - Memory: 8.5%
```

### ドライラン

```bash
$ memguard check --dry-run
空きメモリ: 8% (1310MB / 16384MB)
状態: WARNING (閾値10%以下)

[DRY-RUN] 以下のプロセスを終了予定:
  - node (PID: 12345) - Memory: 25.3%
  - node (PID: 12346) - Memory: 12.1%
```

## ログ例

```
2025-01-15 14:30:00 ==========================================
2025-01-15 14:30:00 memguard v1.1.0 開始
2025-01-15 14:30:00 閾値: 10%, 間隔: 5秒
2025-01-15 14:30:00 対象プロセス: claude|node
2025-01-15 14:30:00 ==========================================
2025-01-15 15:45:32 [WARNING] 空きメモリ低下: 8% (2048MB / 16384MB)
2025-01-15 15:45:32 [ACTION] claude/nodeプロセス 3個を終了します
2025-01-15 15:45:32 [KILL] PID 12345 (node) - Memory: 45.2%
2025-01-15 15:45:34 [KILL] PID 12346 (node) - Memory: 12.1%
2025-01-15 15:45:36 [RESULT] 2個のプロセスを終了 - 空きメモリ: 35% (5734MB / 16384MB)
2025-01-15 15:50:00 [INFO] ログローテーション実行 (10MB → 0MB)
```

## アンインストール

```bash
memguard stop
rm ~/bin/memguard ~/Library/LaunchAgents/local.memguard.plist ~/.memguardrc
```

## earlyoom との比較

| 機能 | earlyoom (Linux) | memguard (macOS) |
|------|------------------|------------------|
| メモリ監視 | ✅ | ✅ |
| スワップ監視 | ✅ | ❌ |
| プロセス指定 | ✅ (--prefer) | ✅ (TARGET_PROCESSES) |
| 通知 | ✅ (D-Bus) | ✅ (通知センター) |
| systemd統合 | ✅ | ✅ (launchd) |
| oom_score使用 | ✅ | ❌ (macOSにはない) |
| ログローテーション | ❌ | ✅ |
| 設定ファイル | ❌ | ✅ |
| CLIコマンド | ❌ | ✅ |
| ドライラン | ❌ | ✅ |

## トラブルシューティング

### サービスが起動しない

```bash
# エラーログを確認
cat /tmp/memguard.stderr.log

# plistの構文チェック
plutil -lint ~/Library/LaunchAgents/local.memguard.plist

# 手動実行でテスト
~/bin/memguard
```

### 通知が表示されない

システム設定 → 通知 → スクリプトエディタ の通知を許可してください。

または、設定ファイルで通知を無効化:
```bash
# ~/.memguardrc
NOTIFY_ENABLED=false
```

### コマンドが見つからない

`~/bin` にPATHが通っているか確認:
```bash
echo $PATH | grep "$HOME/bin"
```

通っていない場合は、`~/.zshrc` に以下を追加:
```bash
export PATH="$HOME/bin:$PATH"
```

## バージョン履歴

### v1.1.0 (2025-01-XX)
- CLIサブコマンド追加 (start/stop/status/check/config/logs など)
- 設定ファイルサポート (~/.memguardrc)
- ワンショットモード (memguard check)
- ドライランモード (--dry-run)
- ログローテーション機能

### v1.0.0 (2025-01-XX)
- 初回リリース
- 基本的なメモリ監視機能
- プロセス自動終了機能
- macOS通知連携

## ライセンス

MIT License
