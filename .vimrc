" +--------------------------------------------------------------------------+
" | Usage                                                                    |
" +--------------------------------------------------------------------------+
" For the most part, this is just a normal vimrc, but there are functions that
" are used to set options, based on the variables below.
" They are:
" 	SetFolding
" 	SetCursorLine
" 	SetTrailingSpace
" 	SetCols80
" 	SetHiddenChars
" 	SetAutoComment
" 	SetMappings TODO
" 	SetMouse
" These can be viewed in editor with ':function /\<Set' or ':fn' if mappings
" are enabled.
"
" These functions all have one integer argument, usually 0 or 1 that will
" change the option. The functions are initially called with their respective
" script-local variable (s:whatever). Since the variables are pretty well
" documented, you shouldn't have too much difficulty figuring things out.

" +--------------------------------------------------------------------------+
" | Variables                                                                |
" +--------------------------------------------------------------------------+
let s:auto_reload = 0            "dynamically change the file as others modify it
let s:dynamicread = 0            " change the file as others modify it
let s:never_wrap = 1             " don't wrap lines. turning this off maps
                                 " j and k to move by actual line, not line number
let s:tabs_to_spaces = 2          " changes tabs to 4 spaces all the time
"let s:tabs_to_spaces = 2         " changes tabs to 4 spaces when editing '.py's
let s:undosaving = 1             " stores undos in a file in ~/.vim/undos
let s:nobackups = 1              " does not store backups or '.swp's
"let s:folding = 1                " allows folding manually or by braces with <space>
let s:folding = 2                " allows folding by syntax
"let s:folding = 3                " allows folding by indent
let s:cursor_line = 1            " that pesky line that keeps following your cursor
let s:spellcheck = 0             " it checks spelling
let s:trailing_whitespace = 1    " highlight trailing whitespace in red
let s:cols_after_80 = 0          " highlight columns after 80, will not work in versions earlier than 7.3 iirc
let s:show_tabs = 0              " show tabs as '>---' also shows '…'s when the rest of a line can't be seen
let s:autocomment = 1            " immediately adds '*' on lines after '/*' but before '*/'
let s:mappings = 1               " the mappings i have set up; they're good
let s:use_mouse = 1              " use of mouse to move cursor and scroll wheel

" may have problems depending on how v:version was maintained.
"    I see comparing v:version to < 720 even though 7.3 is represented as 703,
"    praying that 703 and 702 is the correct way
" Disables unsupported features in earlier versions
if v:version < 703
	let s:undosaving = 0
	let s:cols_after_80 = 0
	if v:version < 702
		let s:cols_after_80 = 0
	endif
endif

" +--------------------------------------------------------------------------+
" | Meta nonsense                                                            |
" +--------------------------------------------------------------------------+
set nocompatible
set termencoding=utf-8
set encoding=utf-8
set hidden
set title
set showcmd             "show command as you type it
set bs=2
set autoindent
set copyindent
set number              "show line numbers
set showmatch           "show matching brackets
set ruler               "constant info at bottom

if s:auto_reload == 1
	au BufWritePost .vimrc so ~/.vimrc
endif
if s:dynamicread == 1
	set autoread
endif

"set whichwrap=h,l       "move up/down a line when h and l are at the beginning/end
if s:never_wrap == 1
	set nowrap              "don't wrap lines like a scrub
else
" for those that actually WANT to wrap lines...make movements work
	noremap j gj
	noremap k gk
	nnoremap <down> gj
	nnoremap <up> gk
endif

" Make tabs = 4 spaces in python files
if s:tabs_to_spaces == 2
	autocmd BufEnter *.py set ts=4 sw=4 expandtab softtabstop=4 backspace=indent
elseif s:tabs_to_spaces == 1
	set ts=4 sw=4 expandtab softtabstop=4 backspace=indent
endif

" +--------------------------------------------------------------------------+
" | Undo stuffs                                                              |
" |   * Save more undos                                                      |
" |   * Remember undos after closing                                         |
" +--------------------------------------------------------------------------+
set undolevels=1000     "be able to undo everything forever
if s:undosaving == 1
	set undofile
	set undodir=~/.vim/undos
endif

" +--------------------------------------------------------------------------+
" | Folder spamming backups begone!                                          |
" +--------------------------------------------------------------------------+
if s:nobackups == 1
	set nobackup
	set noswf
endif

" +--------------------------------------------------------------------------+
" | Folding stuffs                                                           |
" |   * Toggle folding by braces with <space> (only in manual)               |
" |   * Remember what is folded after closing                                |
" +--------------------------------------------------------------------------+
"i broke this on purpose because gvim wasn't saving without error
function SetFolding(num)
	if a:num != 0
		if a:num == 1
			function ToggleFold()
				if foldlevel('.') == 0
					let l:x = line('.')
					let l:c = virtcol('.')
					normal k$
					call search("{")
					if l:x == line('.')
						normal %
						let l:y = line('.')
						execute l:x . "," . l:y . " fold"
					endif
					execute l:x
					execute "normal " . l:c . "|"
				else
					normal zd
				endif
			endfunction

			set foldmethod=manual
			nmap <space> :call ToggleFold()<CR>
		elseif a:num == 2
			set foldmethod=syntax
		elseif a:num == 3
			set foldmethod=indent
		endif
		set foldlevelstart=99
		set foldopen=block,insert,jump,mark,search,undo
		" Remember what's folded and what isn't
		set viewoptions=folds
		"au BufWrite * mkview
		"au BufRead * silent loadview
	endif
endfunction
execute "call SetFolding(".s:folding.")"

" +--------------------------------------------------------------------------+
" | Colors                                                                   |
" |   * Let it be known that colors (darkgray especially) can be screwy if   |
" |        your vim is outdated.                                             |
" +--------------------------------------------------------------------------+
colorscheme torte
"colorscheme danteish
syn on set t_Co=256

" +--------------------------------------------------------------------------+
" | Cursor following and appearance                                          |
" |   * Highlight current line to "black"                                    |
" |   * Vertical line while in INSERT mode                                   |
" |   * Block while in normal mode                                           |
" +--------------------------------------------------------------------------+
function SetCursorLine(num)
	if a:num == 0
		set nocursorline
		hi clear CursorLine
	else
		set cursorline
		hi clear CursorLine
		hi CursorLine ctermbg=black
	endif
endfunction
execute "call SetCursorLine(".s:cursor_line.")"
let &t_SI = "\<Esc>[5 q"
let &t_EI = "\<Esc>[2 q"

" +--------------------------------------------------------------------------+
" | Spell checking setup                                                     |
" |   * Bad spelling highlighted in "red" with "white" letters               |
" |   * Lack of capitalization underlined                                    |
" +--------------------------------------------------------------------------+
setlocal spell spelllang=en_us
hi clear SpellBad
hi clear SpellCap
hi clear SpellRare
hi SpellBad ctermbg=red ctermfg=white
hi SpellCap cterm=underline

if s:spellcheck == 1
	set spell
else
	set nospell
endif

" +--------------------------------------------------------------------------+
" | Highlight trailing whitespace                                            |
" +--------------------------------------------------------------------------+
function SetTrailingSpace(num)
	if a:num == 0
		"TODO
		echo ""
	else
		highlight ExtraWhitespace ctermbg=red guibg=red
		match ExtraWhitespace /\s\+$/
		autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
		autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
		autocmd InsertLeave * match ExtraWhitespace /\s\+$/
		autocmd BufWinLeave * call clearmatches()
	endif
endfunction
execute "call SetTrailingSpace(".s:trailing_whitespace.")"

" +--------------------------------------------------------------------------+
" | Highlight a bajillion columns starting at 80 so I know I've screwed up   |
" +--------------------------------------------------------------------------+
function SetCols80(num)
	if a:num == 0
		hi clear ColorColumn
	else
		execute "set colorcolumn=" . join(range(81,335), ',')
		hi ColorColumn ctermbg=235
	endif
endfunction
execute "call SetCols80(".s:cols_after_80.")"

" +--------------------------------------------------------------------------+
" | Search                                                                   |
" |   * Search as I type                                                     |
" |   * Ignore case in search                                                |
" |   * Override ignorecase if caps are used in search                       |
" +--------------------------------------------------------------------------+
set incsearch
set ignorecase
set smartcase
set hlsearch

" +--------------------------------------------------------------------------+
" | Tab Completion (I never use this but it might be nice one day)           |
" +--------------------------------------------------------------------------+
set wildmenu            "tab completion in menu

" +--------------------------------------------------------------------------+
" | Tabs                                                                     |
" +--------------------------------------------------------------------------+
set showtabline=2
" Commands with C and tab don't work (they might! iterm2 just catches those keys)
nmap <S-tab> :tabn<CR>
imap <S-tab> <Esc>:tabn<CR>i
nnoremap <silent> <C-t> :tabnew<CR>
nnoremap <silent> <C-tab> :tabn<CR>
nnoremap <silent> <C-S-tab> :tabp<CR>

" +--------------------------------------------------------------------------+
" | Fancy tab arrows                                                         |
" +--------------------------------------------------------------------------+
set tabstop=4
set shiftwidth=4
function SetHiddenChars(num)
	if a:num == 0
		set nolist
	else
		set list
		set listchars=tab:>-,extends:…,precedes:…
	endif
endfunction
execute "call SetHiddenChars(".s:show_tabs.")"

" +--------------------------------------------------------------------------+
" | Auto comment                                                             |
" |   * Block comments                                                       |
" +--------------------------------------------------------------------------+
function SetAutoComments(num)
	if a:num == 0
		set formatoptions-=r
		set comments=""
	else
		set formatoptions+=r
		set comments=sl:/*,mb:*,elx:*/
	endif
endfunction
execute "call SetAutoComments(".s:autocomment.")"

" +--------------------------------------------------------------------------+
" | Mappings                                                                 |
" |   * Paste with indent adjustment                                         |
" |   * ; to :                                                               |
" |   * ; to , should I ever use ;                                           |
" |   * In case I hit F1 by accident                                         |
" |   * Yank and paste to OS clipboard WIP                                   |
" |   * Move lines up/down                                                   |
" |   * Force save on readonly files                                         |
" |   * Quit without saving with :qq                                         |
" |   * + and - to <C-a> and <C-x>                                           |
" |   * t and T to insert new lines after and before cursor                  |
" +--------------------------------------------------------------------------+
"function SetMappings(num)
" leave commented until I can unmap if a:num == 0
if s:mappings == 1
	map p ]p
	map P ]P
	nore ; :
	nore , ;
	noremap! <F1> <Esc>
	" don't think this works/I don't know how to use it
	nnoremap <C-y> "+y
	nnoremap <C-S-y> "+yy
	nnoremap <C-p> "+p
	nnoremap <C-S-p> "+P
	" Bubbling up/down
	nmap <S-Up> ddkP
	nmap <S-Down> ddp
	vmap <S-Up> xkP`[V`]
	vmap <S-Down> xp`[V`]

	cmap fn function /\<Set
	cmap w!! %!sudo tee > /dev/null %
	cmap qq q!

	nnoremap + <C-a>
	nnoremap - <C-x>

	nmap t o<Esc>
	nmap T O<Esc>
endif
"execute "call SetMappings(".s:autocomment.")"

" +--------------------------------------------------------------------------+
" | Scrollwheel and mouse                                                    |
" |   * Can click with mouse to move cursor                                  |
" |   * Keep 4 lines between cursor and bottom/top of page                   |
" |   * Scrolling mapped to k/j                                              |
" +--------------------------------------------------------------------------+
function SetMouse(num)
	if a:num == 0
		set mouse=""
		set scrolloff=0
		unmap <ScrollWheelUp>
		unmap <ScrollWheelDown>
	else
		set mouse=n
		set scrolloff=4
		map <ScrollWheelUp>   <Esc>k
		map <ScrollWheelDown> <Esc>j
	endif
endfunction
execute "call SetMouse(".s:use_mouse.")"




