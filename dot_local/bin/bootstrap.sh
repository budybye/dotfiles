#!/usr/bin/env bash
set -ex

# Xcode コマンドラインツールのインストールおよびパスの設定
install_xcode_command_line_tools() {
    echo "Xcode コマンドラインツールのインストールを確認中..."
    if xcode-select -p &>/dev/null; then
        echo "Xcode コマンドラインツールは既にインストールされています。"
    else
        echo "Xcode コマンドラインツールがインストールされていません。インストールを開始します..."
        xcode-select --install

        # インストールが完了するまで待機
        until xcode-select -p &>/dev/null; do
            echo "インストール待機中..."
            sleep 5
        done
        echo "Xcode コマンドラインツールのインストールが完了しました。"
    fi

    # コマンドラインツールのパスを設定
    CURRENT_PATH=$(xcode-select -p)
    DESIRED_PATH="/Library/Developer/CommandLineTools"

    if [ "$CURRENT_PATH" != "$DESIRED_PATH" ]; then
        echo "コマンドラインツールのパスを $DESIRED_PATH に切り替えます。"
        sudo xcode-select --switch "$DESIRED_PATH"

        if [ $? -eq 0 ]; then
            echo "パスの切り替えに成功しました。"
        else
            echo "パスの切り替えに失敗しました。初期設定をリセットします。"
            sudo xcode-select --reset
        fi
    else
        echo "既定のパスが正しく設定されています。"
    fi
}

# Homebrew のインストールおよび設定
install_homebrew() {
    echo "Homebrew のインストールを確認中..."
    if ! command -v brew >/dev/null; then
        echo "Homebrew がインストールされていません。インストールを開始します..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            echo "Homebrewのインストールが失敗しました。"
            exit 1
        }
        echo "Homebrew のインストールが完了しました。"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshenv
    fi
        echo "Homebrew は既にインストールされています。"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "Homebrew の設定が完了しました。"
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
        echo "パッケージのインストールが完了しました。"
    else
        echo "指定された Brewfile ($BREWFILE_PATH) が見つかりません。スキップします。"
    fi
}

# Rosetta 2 のインストール (Apple Silicon の場合)
install_rosetta() {
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo "Apple Silicon Mac を検出しました。Rosetta 2 のインストールを確認中..."
        if /usr/bin/pgrep oahd >/dev/null 2>&1; then
            echo "Rosetta 2 は既にインストールされています。"
        else
            echo "Rosetta 2 をインストールします。"
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license || {
                echo "Rosetta 2 のインストールに失敗しました。"
                exit 1
            }
                echo "Rosetta 2 のインストールに成功しました。"
        fi
    else
        echo "Rosetta 2 は必要ありません (Intel Mac)。"
    fi
}

# メイン処理
main() {
    install_xcode_command_line_tools
    install_homebrew
    install_brew_packages
    install_rosetta
    echo "ブートストラップが完了しました。"

    fastfetch
}

# スクリプトの実行
main
