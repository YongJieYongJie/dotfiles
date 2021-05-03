# Vim Cheatsheet


## Basic Job Control

1. Press `<Ctrl>+z` to minimize Neovim

2. Use `fg` command to restore the last minimized Neovim

3. Use `jobs` command to show all minimized Neovim (and other jobs)

   - The output should look like this:
     ```
     > jobs
     [1]    suspended  ~/neovim/bin/nvim
     [2]  - suspended  vim
     [3]  + suspended  ~/neovim/bin/nvim
     ```

4. Use `%<num>` to restore the particular job, where `<num>`
corresponds to the output of the `jobs` command

_Note: The words "minimize" and "restore" aren't technically the correct,
but they suffices for present purposes._


## Basic text editing

1. Use `j`/`k` and `h`/`l` to move down/up and left/

2. Changing modes:

   - Press `i` to enter insert mode

   - Press `<Ctrl>+[` to enter normal mode (people generally start
   with using `<Esc>` or `<Ctrl>+c`, but eventually prefer this)

   - Press `v` to enter visual select mode


## Navigation (within file)

1. Vanilla Vim (i.e., works in IntelliJ / VSCode once the Vim plugins
are installed):

   - Press `/`/`?` to start search downwards/upwards, `n`/`N` to move
   to next/previous search hit

   - Press `*`/`#` to start start search downwards/upwards for current
   word under cursor

2. Via plugins / extensions:

   - Press `//` to do fuzzy search on lines within file

   - Press `<Ctrl>+o` to do fuzzy search on file structure


## Navigation (across files)

1. Explorer:

   - Press `<Space>e` to open explorer, navigate using `hjkl` and
   other keys as per usual

2. File based:

   - Press `<Space>b` to switch to another opened editor tab by fuzzy
   searching

   - Press `<Space>g` to switch to another file in the Git repository by
   fuzzy searching

   - Press `<Space>z` to switch to another file in the same working
   directory by fuzzy searching

3. Line based:

   - Press `??` to switch to particular line in another file by fuzzy
   searching


## Fuzzing Searching using FZF

1. Searching:

   - Just type words to fuzzy search

   - Prefix a word with `'` for exact match

   - Prefix a word with `!` for negation (e.g., `!test` to exclude tests)

2. Navigating results:

   - `<Ctrl>+j`/`<Ctrl>k` to move up/down results

   - `<Shift>+j`/`<Shift>+k` to scroll up/down the preview

   - Mouse works too


## Code Editing

1. Semantic navigation:

   - `gd`: go to definition / declaration

     - I.e., if you are on a variable `x`, this jumps to where `x` is
     defined / declared

   - `gy`: go to type definition / declaration

     - I.e., if you are on a variable `x` of type `y`, this jumps to
     where `y` is defined / declared

   - `gi`: go to implementation

   - `gr`: go to references / usages

   - `Ctrl+o`: go back (`o` is for `out`)

   - `Ctrl+i`: go forward (`i` is for `in`)

2. Semantic editing:

   - `<Space>a`: show available code actions under cursor
     - e.g., organize imports, extract variables

   - `<Space>rn`: rename identifier under cursor


## Miscellaneous

- Press `:e $MYVIMRC` to open the configuration file. I have added
comments to make it readable (and hopefully educational).


## Notes

- There are 3 types of shortcut keys:

  1. single keystroke (like `j` to move down a line in Vim),

  2. keychords (like `<Cmd>+c` to copy), and

  3. key sequence (like pressing `dd` to delete a line in Vim).

- Regarding terminologies:

  - Vim actually doesn't work on file directly. Instead it loads files
  into buffers.

  - What we commonly refer to as opened editor tabs are actually
  buffers in Vim. Vim's concept of tab is more akin to macOS's spaces.
