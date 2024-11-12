#!/usr/bin/env bash
set -ex

# Xcode コマンドラインツールのインストールおよびパスの設定
install_xcode_command_line_tools() {
    echo "Xcode コマンドラインツールのインストール中..."
    command -v xcode-select -p >/dev/null || xcode-select --install || {
        echo "Xcode コマンドラインツールのインストールに失敗しました。"
        exit 1
    }
    echo "Xcode コマンドラインツールのインストールが完了しました。"
    CURRENT_PATH=$(xcode-select -p)
    DESIRED_PATH="/Library/Developer/CommandLineTools"

    if [ "$CURRENT_PATH" != "$DESIRED_PATH" ]; then
        echo "コマンドラインツールのパスを $DESIRED_PATH に切り替えます。"
        sudo xcode-select --switch "$DESIRED_PATH" || {
            echo "パスの切り替えに失敗しました。初期設定をリセットします。"
            sudo xcode-select --reset
        }
    fi
    echo "$DESIRED_PATH の設定が完了しました。"
}

# Homebrew のインストールおよび設定
install_homebrew() {
    echo "Homebrew のインストール中..."
    command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        echo "Homebrewのインストールが失敗しました。"
        exit 1
    }
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Brewfile を使用してパッケージをインストール
install_brew_packages() {
    BREWFILE_PATH="$HOME/.config/Brewfile-test"

    if [ -f "$BREWFILE_PATH" ]; then
        echo "Brewfile ($BREWFILE_PATH) からパッケージをインストールします。"
        brew tap Homebrew/bundle
        brew bundle --file="$BREWFILE_PATH" || {
            echo "brew bundleのインストールが失敗しました。"
            exit 1
        }
    else
        echo "指定された Brewfile ($BREWFILE_PATH) が見つかりません。スキップします。"
    fi
    echo "パッケージのインストールが完了しました。"
}

# Rosetta 2 のインストール (Apple Silicon の場合)
install_rosetta() {
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo "Apple Silicon Mac を検出しました。Rosetta 2 のインストールを確認中..."
        /usr/bin/pgrep oahd >/dev/null || /usr/sbin/softwareupdate --install-rosetta --agree-to-license || {
            echo "Rosetta 2 のインストールに失敗しました。"
            exit 1
        }
    else
        echo "Rosetta 2 は必要ありません (Intel Mac)。"
    fi
    echo "Rosetta 2 のインストールに成功しました。"
}

# メイン処理
main() {
    echo "ブートストラップを開始します。"
    install_xcode_command_line_tools
    install_homebrew
    install_brew_packages
    install_rosetta
    echo "ブートストラップが完了しました。"
    fastfetch
}

# スクリプトの実行
main
