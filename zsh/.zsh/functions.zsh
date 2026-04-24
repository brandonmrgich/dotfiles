# shellcheck shell=bash
# functions.zsh — shell functions

youtube-dl() {
    yt-dlp -x --audio-format mp3 --audio-quality 0 --default-search ytsearch "$@"
}

tarxz() {
    local folder="${1}"
    tar -cvJf "${folder}.tar.xz" "${folder}"
}
