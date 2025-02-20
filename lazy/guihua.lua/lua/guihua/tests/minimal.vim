set rtp +=.
set rtp +=../plenary.nvim/
set rtp +=../guihua.lua/

runtime! plugin/plenary.vim
runtime! plugin/guihua.vim

set noswapfile
set nobackup

filetype indent off
set nowritebackup
set noautoindent
set nocindent
set nosmartindent
set indentexpr=


lua << EOF
_G.test_rename = true
_G.test_close = true
require("plenary/busted")
-- for testing load gopls ahead
EOF
