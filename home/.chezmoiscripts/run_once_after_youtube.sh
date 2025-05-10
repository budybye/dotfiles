#!/usr/bin/env bash

echo "run_once_after_youtube.sh"
echo "--------------------------------"

PLAYLIST_DIR="$HOME/Music/riddim"
PLAYLIST_ID="PLMXoRsxtzGfCH7cvhAnzN_T3KvKmdkB3s"

function install_yt_dlp() {
    if ! command -v yt-dlp > /dev/null 2>&1; then
        if command -v brew > /dev/null 2>&1; then
            brew install yt-dlp
        elif command -v apt > /dev/null 2>&1; then
            sudo apt-get install -y yt-dlp
        elif command -v mise > /dev/null 2>&1; then
            mise use -g -y yt-dlp
        else
            echo "yt-dlp is not installed"
        fi
    fi
    echo "yt-dlp installed"
}

function install_ffmpeg() {
    if ! command -v ffmpeg > /dev/null 2>&1; then
        if command -v brew > /dev/null 2>&1; then
            brew install ffmpeg
        elif command -v apt > /dev/null 2>&1; then
            sudo apt-get install -y ffmpeg
        elif command -v mise > /dev/null 2>&1; then
            mise use -g -y ffmpeg
        else
            echo "ffmpeg is not installed"
        fi
    fi
    echo "ffmpeg installed"
}

# ダウンロード先ディレクトリの存在しなければダウンロード
function download_playlist() {
    if [ ! -d "$PLAYLIST_DIR" ]; then
        mkdir -p "$PLAYLIST_DIR"
        # ダウンロード
        yt-dlp \
          --audio-format mp3 \
          --format bestaudio \
          --audio-quality 0 \
          --extract-audio \
          --output "${PLAYLIST_DIR}/%(title)s.%(ext)s" \
          --ignore-errors \
          --no-warnings \
          "https://youtube.com/playlist?list=${PLAYLIST_ID}"
    fi
    ls -l "$PLAYLIST_DIR"
}

# インストール
install_yt_dlp
install_ffmpeg
# ダウンロード
download_playlist
