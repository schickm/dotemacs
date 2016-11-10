" Plugins
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'editorconfig/editorconfig-vim'
Plug 'airblade/vim-gitgutter'
Plug 'rakr/vim-one'
call plug#end()

set mouse=a " Enable mouse in all modes
set updatetime=250 " Faster update time for gitgutter
set number " Show line numbers always
set hidden " Allow switching away from modified buffers
set confirm " have vim prompt for saving modified buffers
set wildchar=<Tab> wildmenu wildmode=full " nicer wildcard mode
set scrolloff=5 " atleast 5 lines above the edges 
set autoindent

" colorization settings
if (has("termguicolors"))
    set termguicolors
endif

set background=light
let g:one_allow_italics=1
colorscheme one

" Highlight more characters then the default
set list lcs=eol:$,tab:→∙,space:▫︎
set list!
