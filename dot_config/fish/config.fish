#*****************************
#* エイリアスの独自設定
#*****************************
# ssh接続ツールのエイリアスを設定（独自ツール）
alias sshc='sh $HOME/.tool/ssh_connection/ssh_connection.sh'

# eroge_release_cmdのエイリアスを設定（独自ツール）
alias getchuya='cd $HOME/.tool/eroge_release_cmd/;bundle exec getchuya'

# qiita_command を使用してQiitaのトレンドを取得するエイリアス設定（独自ツール）
alias qiita='$HOME/.tool/qiita_command/qiita'

# hostsファイルをVSCodeで開く
alias hosts='sudo code /private/etc/hosts'

# .bashrcファイルをVSCodeで開く
alias bashrc='code ~/.bashrc'

# .bash_profileファイルをVSCodeで開く
alias bash_profile='code ~/.bash_profile'

# config.fishファイルをVSCodeで開く
alias config.fish='code ~/.config/fish/config.fish'

#*****************************
#* fishの色用定数
#*****************************
set normal (set_color normal)
set magenta (set_color magenta)
set yellow (set_color yellow)
set green (set_color green)
set red (set_color red)
set gray (set_color -o black)

#*****************************
#* Git用の設定
#*****************************
# Fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red

# Status Chars
set __fish_git_prompt_char_dirtystate '⚡'
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_untrackedfiles '☡'
set __fish_git_prompt_char_stashstate '↩'
set __fish_git_prompt_char_upstream_ahead '+'
set __fish_git_prompt_char_upstream_behind '-'

#*****************************
#* プロンプトの独自設定
#*****************************
# 左側
function fish_prompt
    set -l last_status $status

    set_color $fish_color_user
    printf 'ユーザー名 > %s%s' (basename (pwd)) (__fish_git_prompt)

    __fish_hg_prompt
    echo

    if not test $last_status -eq 0
        set_color $fish_color_error
    end

    echo -n '➤ '
    set_color normal
end
# 右側
function fish_right_prompt
    set_color yellow
    echo (date +'%Y-%m-%d %H:%M:%S')
end
