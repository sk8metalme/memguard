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
echo "[1/5] ~/bin ディレクトリを作成..."
mkdir -p "$HOME/bin"

# 2. memguard スクリプトをコピー
echo "[2/5] memguard をインストール..."
cp "$SCRIPT_DIR/memguard" "$HOME/bin/memguard"
chmod +x "$HOME/bin/memguard"
echo "      → $HOME/bin/memguard"

# 3. 設定ファイルをコピー（既存の設定ファイルがない場合のみ）
echo "[3/5] 設定ファイルを確認..."
if [ -f "$HOME/.memguardrc" ]; then
    echo "      既存の設定ファイルを保持: ~/.memguardrc"
else
    if [ -f "$SCRIPT_DIR/memguardrc.example" ]; then
        cp "$SCRIPT_DIR/memguardrc.example" "$HOME/.memguardrc"
        echo "      → ~/.memguardrc"
    else
        echo "      設定ファイルのサンプルが見つかりません（スキップ）"
    fi
fi

# 4. LaunchAgent をインストール
echo "[4/5] LaunchAgent をインストール..."
mkdir -p "$HOME/Library/LaunchAgents"

# plistファイルの$HOMEを実際のパスに置換
sed "s|\$HOME|$HOME|g" "$SCRIPT_DIR/local.memguard.plist" > "$HOME/Library/LaunchAgents/local.memguard.plist"
echo "      → $HOME/Library/LaunchAgents/local.memguard.plist"

# 5. LaunchAgent を有効化
echo "[5/5] LaunchAgent を有効化..."

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
echo "  - 設定ファイル: ~/.memguardrc"
echo ""
echo "コマンド:"
echo "  状態確認:   memguard status"
echo "  メモリチェック: memguard check"
echo "  設定確認:   memguard config"
echo "  ログ確認:   memguard logs"
echo "  停止:       memguard stop"
echo "  再開:       memguard start"
echo "  ヘルプ:     memguard help"
echo ""
echo "アンインストール:"
echo "  memguard stop"
echo "  rm ~/bin/memguard ~/Library/LaunchAgents/local.memguard.plist ~/.memguardrc"
echo ""
echo "注意: ~/bin にPATHが通っていない場合は、以下を ~/.zshrc に追加してください:"
echo "  export PATH=\"\$HOME/bin:\$PATH\""
echo ""
