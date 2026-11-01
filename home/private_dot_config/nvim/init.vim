" ================================================================================
" init.vim
" ================================================================================
set encoding=utf-8
scriptencoding utf-8
" ↑1行目は読み込み時の文字コードの設定
" ↑2行目はVim Script内でマルチバイトを使う場合の設定
" Vim scritptにvimrcも含まれるので、日本語でコメントを書く場合は先頭にこの設定が必要になる

" 文字コードを UFT-8 に設定する
set fenc=utf-8

" バックアップファイルを作らない
set nobackup

" スワップファイルを作らない
set noswapfile

" 編集中のファイルが変更されたら自動で読み直す
set autoread

" バッファが編集中でもその他のファイルを開けるようにする
set hidden

" 入力中のコマンドをステータスに表示する
set showcmd

" クリップボード連携を有効にする (MacOS の場合は unnamedplus ではなく unnamed で有効にできた・vi ではなく vim を使うこと)
set clipboard&
set clipboard^=unnamed

" クリップボード連携を有効にした時に BackSpace (Delete) が効かなくなるので設定する
set backspace=indent,eol,start

" 見た目
" ------------------------------------------------------------

" Monokai カラースキーム
colorscheme monokai

" 範囲選択が見づらいので変更する
hi Visual ctermbg=227

" 構文に色を付ける
syntax enable
syntax on

" 行番号を表示する
set number

" 現在の行を強調表示する
set cursorline

" カーソルラインの色をクリアする
hi clear CursorLine
" set cursorLine

" 行末の1文字先までカーソルを移動できるようにする
set virtualedit=onemore

" スマートインデントにする
set smartindent

" ビープ音を可視化する
set visualbell

" 括弧入力時の対応する括弧を表示する
set showmatch

" ステータスラインを常に表示する
set laststatus=2

" 現在のモードを表示
set showmode
" 打ったコマンドをステータスラインの下に表示
set showcmd
" ステータスラインの右側にカーソルの位置を表示する
set ruler

" コマンドライン補完を有効にする
set wildmode=list:longest

" 行が折り返し表示されていた場合、行単位ではなく表示行単位でカーソルを移動する
nnoremap j gj
nnoremap k gk
nnoremap <down> gj
nnoremap <up> gk

"左のタブに移動
nnoremap <C-h> gT
"右のタブに移動
nnoremap <C-l> gt
"新しくタブを開く
nnoremap <C-t> :<C-u>tabnew<CR>

"[insert mode] 行頭へ移動
inoremap <C-a> <C-o>^
"[insert mode] 行末へ移動
inoremap <C-e> <C-o>$

" バックスペースキーの有効化
set backspace=indent,eol,start

" Tab 文字
" ------------------------------------------------------------

" 不可視文字を可視化 (タブが「▸-」と表示される)
set list listchars=tab:\▸\-

" Tab 文字を半角スペースにする
set expandtab

" 行頭以外の Tab 文字の表示幅 (スペースの数)
set tabstop=2

" 行頭での Tab 文字の表示幅
set shiftwidth=2

" 保存時の文字コード
set fileencoding=utf-8

" 読み込み時の文字コードの自動判別. 左側が優先される
set fileencodings=ucs-boms,utf-8,euc-jp,cp932

" 改行コードの自動判別. 左側が優先される
set fileformats=unix,dos,mac

" □や○文字が崩れる問題を解決
set ambiwidth=double

" 検索
" ------------------------------------------------------------

" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase

" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase

" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch

" 検索時に最後まで行ったら最初に戻る
set wrapscan

" 検索語をハイライト表示する
set hlsearch

" ウィンドウ
" ------------------------------------------------------------

" t + \ ・ t + | でウィンドウを垂直縦分割する
nmap t<Bslash> :vsplit<Return><C-w>w
nmap t<Bar> :vsplit<Return><C-w>w
" t + - でウィンドウを水平横分割する
nmap t- :split<Return><C-w>w

" t + hjkl でウィンドウ移動する
nnoremap th <C-w>h
nnoremap tj <C-w>j
nnoremap tk <C-w>k
nnoremap tl <C-w>l
" t + HJKL でウィンドウをリサイズする
nmap tH <C-w>>
nmap tJ <C-w>-
nmap tK <C-w>+
nmap tL <C-w><

" t + 矢印キーでウィンドウ移動する
nnoremap t<Left> <C-w>h
nnoremap t<Down> <C-w>j
nnoremap t<Up> <C-w>k
nnoremap t<Right> <C-w>l
" Ctrl + w → 矢印キーでウィンドウをリサイズする
nmap <C-w><Left> <C-w>>
nmap <C-w><Down> <C-w>-
nmap <C-w><Up> <C-w>+
nmap <C-w><Right> <C-w><

" Space でウィンドウ移動する
nmap <Space> <C-w>w

" Tab・Shift + Tab でタブ移動
nmap <Tab> :tabnext<Return>
nmap <S-Tab> :tabprev<Return>

" Ctrl + z で元に戻す (u)
nnoremap <C-z> u
" Ctrl + y でやり直す (Ctrl + r)
nnoremap <C-y> <C-r>

" Esc 連打で :nohlsearch が出ないようにする
nnoremap <Esc><Esc> <Esc>

"コマンドモード
" ------------------------------------------------------------

" コマンドモードの補完
set wildmenu
" 保存するコマンド履歴の数
set history=5000

" タブ・インデント
" ------------------------------------------------------------
" タブ入力を複数の空白入力に置き換える
set expandtab
" 画面上でタブ文字が占める幅
set tabstop=4
" 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set softtabstop=4
" 改行時に前の行のインデントを継続する
set autoindent
" 改行時に前の行の構文をチェックし次の行のインデントを増減する
set smartindent
" smartindentで増減する幅
set shiftwidth=4

" マウスでカーソル移動とスクロール
" ----------------------------------------------------------
if has('mouse')
    set mouse=a
    " Neovim では ttymouse オプションは存在しない (常に SGR mouse reporting を使用)
    if !has('nvim')
        if has('mouse_sgr')
            set ttymouse=sgr
        elseif v:version > 703 || v:version is 703 && has('patch632')
            set ttymouse=sgr
        else
            set ttymouse=xterm2
        endif
    endif
endif

" クリップボードからのペースト
" ----------------------------------------------------------
" 挿入モードでクリップボードからペーストする時に自動でインデントさせないようにする
" Neovim では pastetoggle オプションはサポートされていないため、Vim 専用の設定
if !has('nvim') && &term =~ "xterm"
    let &t_SI .= "\e[?2004h"
    let &t_EI .= "\e[?2004l"
    let &pastetoggle = "\e[201~"

    function XTermPasteBegin(ret)
        set paste
        return a:ret
    endfunction

    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif
