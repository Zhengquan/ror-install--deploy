simple vimrc for ruby 
=====================
	set nocompatible
	set autoindent
	set nu
	call pathogen#infect()
	syntax on
	filetype plugin indent on
	au FileType ruby setlocal expandtab
	au FileType ruby setlocal tabstop=2 shiftwidth=2 softtabstop=2
	au FileType ruby setlocal cindent
	au FileType ruby setlocal smartindent
	au FileType ruby setlocal autoindent
	
	au FileType sh setlocal tabstop=4 shiftwidth=4 softtabstop=4
	au FileType sh setlocal cindent
	au FileType sh setlocal smartindent
	au FileType sh setlocal autoindent
