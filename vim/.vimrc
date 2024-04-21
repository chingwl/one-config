" setup folds {{{
augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}

" configs {{{
set nocompatible  " 以不兼容方式运行Vim 如果启用，许多Vim特有的功能将会被禁止 nocp=nocompatible
set ruler " 打开状态栏标尺 用于在编辑窗口的右下角显示一个状态栏。
set showmode " 显示当前模式
set number " 显示行号
set relativenumber " 启用相对行号
set cindent " 自动缩进
set smartindent " 开启新行时使用智能自动缩进
set autoindent " 按下回车键后，下一行的缩进会自动跟上一行的缩进保持一致。
set showmatch " 插入括号时，短暂地跳转到匹配的对应括号
set ignorecase smartcase " 搜索匹配，都是小写时匹配大写和小写，当有一个是大写时严格匹配大小写。 加\C进行严格大小写匹配
set hlsearch  incsearch " 设置搜索高亮 hls=hlsearch is=incsearch(启用增量搜索,输入搜索模式时立即根据当前输入的内容进行实时搜索，而不需要按下回车键来执行搜索)
set clipboard+=unnamed " 使用系统剪切板
set hidden " 若没有配置该选项，当您想切换buffer且当前buffer没有保存时，Vim将提示您保存文件（如果您想快速切换，您不会想要这个提示）
set history=10000 " 设置保留的历史记录条数 默认值是20
set nowrap " 禁用自动换行显示功能
set mouse=a " 支持使用鼠标
set encoding=utf-8 " 设置字符编码
set t_Co=256 " 启用256色
" set scrolloff=3 " 设置滚动时光标离屏幕顶部和底部的行数
" set paste  " 启用粘贴模式 (注意启用后 imap 不生效)
syntax on " 自动语法高亮
filetype plugin on " 用于打开文件类型检测和插件功能
filetype indent on " 开启文件类型检查，并且载入与该类型对应的缩进规则。比如，如果编辑的是.py文件，Vim 就是会找 Python 的缩进规则~/.vim/indent/python.vim
" }}}

" mappings {{{
" 普通模式下空格映射为 :
noremap <space> :
" insert模式下 jk --> ESC
imap jk <ESC>
" 模拟 Emacs 键绑定
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-u> <Esc>0c$
inoremap <C-d> <Esc><Right>s
" }}}

" functions {{{

" 自动切换 vim 中文输入法
let g:lv_restore_last_im = 0
function! AutoIM(event)
    let is_abc = system('is_abc') != ''

    let need_switch_im = 0
    if a:event == 'leave'
        if !is_abc
            let g:lv_restore_last_im = 1
            let need_switch_im = 1
        else
            let g:lv_restore_last_im = 0
        end
    else " a:event == 'enter'
        if is_abc && g:lv_restore_last_im
            let need_switch_im = 1
        end
    end

    if need_switch_im
        silent !osascript ~/.config/nvim/f17.scpt
    end
endfunction
autocmd InsertEnter * call AutoIM("enter")
autocmd InsertLeave * call AutoIM("leave")

" }}}

" plugins {{{

" call plug#begin('~/.vim/plugged')
"   Plug 'mattn/emmet-vim'
"   Plug 'preservim/nerdtree'
" call plug#end()

" }}}

" vim study card {{{

" type ,, (that's comma comma)
" You know the command pretty well, but not enough to move it to 'Known'.
" ,, moves the current command to the bottom of the 'Study' queue.
" nmap ,, ^v/^$<cr>dma/^= Known<cr>P'azt<c-y><c-l>

" type ,c (that's comma c)
" You don't really know the command at all and want to see it again soon.
" ,c moves the current command down a several positions in the 'Study' queue
" so you'll see it again soon.
" nmap ,c ^v/^$<cr>dma/^$<cr>/^$<cr>/^$<cr>/^$<cr>jP'azt<c-y><c-l>:noh<cr>

" type ,k (that's comma k)
" You have the command down cold.  Move it to the 'Known' queue.
" ,k moves the current command into the 'Known' queue.
" nmap ,k ^v/^$<cr>dma/^= Known<cr>jjP'azt<c-y><c-l>

" }}}