# obsession.vim

A fork of Tim Pope's [obsession.vim](https://github.com/tpope/vim-obsession).

This fork will only save session data after a buffer has been saved to
disk. 

## obsession.vim

Use `:Obsess` (with optional file/directory name) to start recording to a
session file and `:Obsess!` to stop and throw it away.  That's it.  Load a
session in the usual manner: `vim -S`, or `:source` it.

There's also an indicator you can put in `'statusline'`, `'tabline'`, or
`'titlestring'`.  See `:help obsession-status`.

### Installation

If you don't have a preferred installation method, Tim Pope recommends
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/studio-vx/vim-obsession.git
    vim -u NONE -c "helptags vim-obsession/doc" -c q
