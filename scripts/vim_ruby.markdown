simple vimrc for ruby 
=====================
	set nu
	syntax on
	filetype plugin indent on
	set nocompatible
	au FileType ruby setlocal expandtab
	au FileType ruby setlocal tabstop=2 shiftwidth=2 softtabstop=2
	au FileType ruby setlocal cindent
	au FileType ruby setlocal smartindent
	au FileType ruby setlocal autoindent
