#!/bin/bash
#
# memguard インストールスクリプト
# macOS用メモリ監視デーモンをセットアップします
#

set -e

echo "========================================"
echo "memguard インストーラー"
echo "========================================"
echo ""

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. ~/bin ディレクトリを作成
echo "[1/4] ~/bin ディレクトリを作成..."
mkdir -p "$HOME/bin"

# 2. memguard スクリプトをコピー
echo "[2/4] memguard をインストール..."
cp "$SCRIPT_DIR/memguard" "$HOME/bin/memguard"
chmod +x "$HOME/bin/memguard"
echo "      → $HOME/bin/memguard"

# 3. LaunchAgent をインストール
echo "[3/4] LaunchAgent をインストール..."
mkdir -p "$HOME/Library/LaunchAgents"

# plistファイルの$HOMEを実際のパスに置換
sed "s|\$HOME|$HOME|g" "$SCRIPT_DIR/local.memguard.plist" > "$HOME/Library/LaunchAgents/local.memguard.plist"
echo "      → $HOME/Library/LaunchAgents/local.memguard.plist"

# 4. LaunchAgent を有効化
echo "[4/4] LaunchAgent を有効化..."

# 既存のサービスがあれば停止
launchctl unload "$HOME/Library/LaunchAgents/local.memguard.plist" 2>/dev/null || true

# サービスを開始
launchctl load "$HOME/Library/LaunchAgents/local.memguard.plist"

echo ""
echo "========================================"
echo "✅ インストール完了!"
echo "========================================"
echo ""
echo "memguard は今すぐ実行されており、ログイン時に自動起動します。"
echo ""
echo "設定:"
echo "  - 閾値: 10% (空きメモリ)"
echo "  - 対象: claude, node プロセス"
echo "  - ログ: ~/.memguard.log"
echo ""
echo "コマンド:"
echo "  状態確認:   launchctl list | grep memguard"
echo "  ログ確認:   tail -f ~/.memguard.log"
echo "  停止:       launchctl unload ~/Library/LaunchAgents/local.memguard.plist"
echo "  再開:       launchctl load ~/Library/LaunchAgents/local.memguard.plist"
echo "  アンインストール:"
echo "              launchctl unload ~/Library/LaunchAgents/local.memguard.plist"
echo "              rm ~/bin/memguard ~/Library/LaunchAgents/local.memguard.plist"
echo ""
