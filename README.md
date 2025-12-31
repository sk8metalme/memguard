# memguard - macOS用メモリ監視デーモン

Linux の `earlyoom` に相当するmacOS用のメモリ監視ツールです。
システムの空きメモリが閾値以下になると、指定したプロセス(claude/node)を自動終了します。

## 機能

- 🔍 5秒ごとにシステムメモリを監視
- ⚠️ 空きメモリが10%以下で警告
- 🔪 claude/nodeプロセスを自動終了 (SIGTERM → SIGKILL)
- 📢 macOS通知センターに通知
- 📝 ログファイルに記録
- 🚀 Mac起動時に自動実行

## インストール

```bash
# ダウンロードしたディレクトリで実行
chmod +x install-memguard.sh
./install-memguard.sh
```

## 使い方

### 状態確認

```bash
# サービスの実行状態
launchctl list | grep memguard

# リアルタイムログ
tail -f ~/.memguard.log
```

### 制御

```bash
# 停止
launchctl unload ~/Library/LaunchAgents/local.memguard.plist

# 再開
launchctl load ~/Library/LaunchAgents/local.memguard.plist

# 手動実行 (デバッグ用)
~/bin/memguard
```

### アンインストール

```bash
launchctl unload ~/Library/LaunchAgents/local.memguard.plist
rm ~/bin/memguard
rm ~/Library/LaunchAgents/local.memguard.plist
rm ~/.memguard.log
```

## 設定変更

`~/bin/memguard` を編集して設定を変更できます:

```bash
# === 設定 ===
THRESHOLD_PERCENT=10       # 空きメモリ閾値 (%) ← 変更可能
CHECK_INTERVAL=5           # チェック間隔 (秒) ← 変更可能
LOG_FILE="$HOME/.memguard.log"
TARGET_PROCESSES="claude|node"  # 対象プロセス ← 変更可能
```

変更後はサービスを再起動:

```bash
launchctl unload ~/Library/LaunchAgents/local.memguard.plist
launchctl load ~/Library/LaunchAgents/local.memguard.plist
```

## ログ例

```
2025-01-15 14:30:00 ==========================================
2025-01-15 14:30:00 memguard 開始 (閾値: 10%, 間隔: 5秒)
2025-01-15 14:30:00 対象プロセス: claude|node
2025-01-15 14:30:00 ==========================================
2025-01-15 15:45:32 [WARNING] 空きメモリ低下: 8% (2048MB / 16384MB)
2025-01-15 15:45:32 [ACTION] claude/nodeプロセス 3個を終了します
2025-01-15 15:45:32 [KILL] PID 12345 (node) - Memory: 45.2%
2025-01-15 15:45:34 [KILL] PID 12346 (node) - Memory: 12.1%
2025-01-15 15:45:36 [RESULT] 2個のプロセスを終了 - 空きメモリ: 35% (5734MB / 16384MB)
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

## トラブルシューティング

### サービスが起動しない

```bash
# エラーログを確認
cat /tmp/memguard.stderr.log

# plistの構文チェック
plutil -lint ~/Library/LaunchAgents/local.memguard.plist
```

### 通知が表示されない

システム設定 → 通知 → スクリプトエディタ の通知を許可してください。

## ライセンス

MIT License
