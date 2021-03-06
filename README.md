# vim-visual-history

A Vim plugin that keeps a traversable history of previous visual selections

*This plugin is in an initial testing phase. While it should always be
functional, anything can change at any time and documentation maybe lacking.*

## Table of contents
* [Feature Demos](#feature-demos)
    * [Traversing different types of visual selection](#traversing-different-types-of-visual-selection)
    * [You can also give a count](#you-can-also-give-a-count)
* [Usage](#usage)
    * [Traversing the visual selection history](#traversing-the-visual-selection-history)
    * [Settings](#settings)
        * [Prevent automatic creation of mappings](#prevent-automatic-creation-of-mappings)
        * [Specify the length of the visual history](#specify-the-length-of-the-visual-history)
* [Installation](#installation)
* [Contribution guidelines](#contribution-guidelines)
    * [Report a bug](#report-a-bug)
    * [Request a feature](#request-a-feature)
* [My other plugins](#my-other-plugins)
* [License](#license)

## Feature demos

### Traversing different types of visual selection

![demo](https://github.com/Matt-A-Bennett/vim_plugin_external_docs/blob/master/vim-visual-history/visual_history_annotated.gif)

### You can also give a count

![demo](https://github.com/Matt-A-Bennett/vim_plugin_external_docs/blob/master/vim-visual-history/visual_history_count_annotated.gif)

## Usage

### Traversing the visual selection history

In visual and in normal mode, 4 commands are defined:

```
[count][v : Reselect [count] previous visual selections
[count]]v : Reselect [count] next visual selections
       [V : Reselect first visual selection
       ]V : Reselect last visual selection
```

Note that the visual history is only updated when the cursor moves (in any
mode). For example, a single press of `V` to select an line can't be
immediately reselected with the above commands (although |gv| will still work).


The following Ex command is also available:

```
:ClearVisualHistory : Remove all visual history for the local buffer
```

### Settings

#### Prevent automatic creation of mappings

By default visual-history creates the above mappings. If you would rather it
didn't do this (for instance if you already have those key combinations mapped
to something else) you can turn them off with:

```vim
let g:visual_history_create_mappings = 0
```

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

#### Specify the length of the visual history

By default the 'visual-history' plugin remembers your last 100 visual
selections. To change this default, add this to your .vimrc:

```vim
let g:visual_history_length = <any number greater than 0>
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

## Contribution guidelines

### Report a bug

First, check if the bug is already known by seeing whether it's listed on the
[visual-history todo list](https://github.com/Matt-A-Bennett/vim_plugin_external_docs/blob/master/vim-visual-history/todo.md).

If it's not there, then please raise a [new
issue](https://github.com/Matt-A-Bennett/vim-visual-history/issues) (or submit a
pull request) so I can fix it.

### Request a feature

First, check if the feature is already planned by looking at the 
[visual-history todo list](https://github.com/Matt-A-Bennett/vim_plugin_external_docs/blob/master/vim-visual-history/todo.md).

If it's not there, then please raise a [new
issue](https://github.com/Matt-A-Bennett/vim-visual-history/issues) describing what
you would like and I'll see what I can do! If you would like to submit a pull
request, then do so (please let me know this is your plan first in a [new issue](https://github.com/Matt-A-Bennett/vim-visual-history/issues)).

## My other plugins
 - [vim-surround-funk](https://github.com/Matt-A-Bennett/vim-surround-funk):  A
   Vim plugin to manipulate function calls 
 - [vim-visual-history](https://github.com/Matt-A-Bennett/vim-visual-history):
   A Vim plugin that keeps a traversable history of previous visual selections
                       
## License
 Copyright (c) Matthew Bennett. Distributed under the same terms as Vim itself.
 See `:help license`.

