# vim-visual-history

A Vim plugin that keeps a traversable record of previous visual selections

*This plugin is in an initial testing phase. While it should always be
functional, anything can change at any time and documentation maybe lacking.*

In visual and in normal mode, 4 commands are defined:

```
[v : Reselect previous visual selection
]v : Reselect next visual selection
[V : Reselect first visual selection
]V : Reselect last visual selection
```

Note that only visual selections where the cursor moves are remembered (so
doing `V` to select a line won't work unless you additionally move the cursor
at least one character to the left or right).

By default visual-history creates the above mappings. If you would rather it
didn't do this (for instance if you already have those key combinations mapped
to something else) you can turn them off with:

And map them to something different with:

```vim
<mode>map <your-map-here> <Plug>(<OperationToMap>)
```

For reference, the default mappings are as follows:

```vim
" visual mode commands
vmap <silent> [v <Plug>(SelectPrevious)
vmap <silent> ]v <Plug>(SelectNext)
vmap <silent> [V <Plug>(SelectFirst)
vmap <silent> ]V <Plug>(SelectLast)

" normal mode commands
nmap <silent> [v <Plug>(SelectPrevious)
nmap <silent> ]v <Plug>(SelectNext)
nmap <silent> [V <Plug>(SelectFirst)
nmap <silent> ]V <Plug>(SelectLast)
```

## Installation

Use your favorite plugin manager.

- [Vim-plug][vim-plug]

    ```vim
    Plug 'Matt-A-Bennett/vim-visual-history'
    ```

- [NeoBundle][neobundle]

    ```vim
    NeoBundle 'Matt-A-Bennett/vim-visual-history'
    ```

- [Vundle][vundle]

    ```vim
    Plugin 'Matt-A-Bennett/vim-visual-history'
    ```

- [Pathogen][pathogen]

    ```sh
    git clone git://github.com/Matt-A-Bennett/vim-visual-history.git ~/.vim/bundle/vim-visual-history
    ```

[neobundle]: https://github.com/Shougo/neobundle.vim
[vundle]: https://github.com/gmarik/vundle
[vim-plug]: https://github.com/junegunn/vim-plug
[pathogen]: https://github.com/tpope/vim-pathogen

## My other plugins
 - [vim-surround-funk](https://github.com/Matt-A-Bennett/vim-surround-funk):  A
   Vim plugin to manipulate function calls 
 - [vim-visual-history](https://github.com/Matt-A-Bennett/vim-visual-history):
   A Vim plugin that keeps a traversable record of previous visual selections
                       
## License
 Copyright (c) Matthew Bennett. Distributed under the same terms as Vim itself.
 See `:help license`.

