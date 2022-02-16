<img src="https://neovim.io/logos/neovim-mark-flat.png" align="right" width="144" />

# nvim-config-local 1.0.0

Secure load local config files.

[![Awesome Neovim](https://awesome.re/badge-flat.svg)](https://github.com/rockerBOO/awesome-neovim)

Vim provides a feature called `exrc`, which allows to use config files that are
local to the current working directory. However, unconditionally sourcing
whatever files we might have in our current working directory can be
potentially dangerous. Because of that, neovim has disabled the feature. The
plugin tries to solve this issue by keeping track of file hashes and allowing
only trusted files to be sourced.

## Usage

When the plugin detects a new config file, it will ask what do you want to do
with it:

```
[config-local]: Unknown config file found: ".vimrc"
[s]kip, (o)pen, (i)gnore, (t)rust:
```

You can either `s`kip this file for now, `o`pen it to see if it doesn't contain
anything malicious, `i`ignore the file so `config-local` won't ask you about it
again, or `t`rust (mark it trusted) and source it right away.

To manually mark file as trusted, open the config file with `:edit .vimrc` or
`:ConfigEdit` and save it. You will be asked to trust the current config file.

File has to be marked as trusted each time its contents or path changes.

## Install

with [packer](https://github.com/wbthomason/packer.nvim):

```lua

use {
  "klen/nvim-config-local",
  config = function()
    require('config-local').setup {
      -- Default configuration (optional)
      config_files = { ".vimrc.lua", ".vimrc" },  -- Config file patterns to load (lua supported)
      hashfile = vim.fn.stdpath("data") .. "/config-local", -- Where the plugin keeps files data
      autocommands_create = true,                 -- Create autocommands (VimEnter, DirectoryChanged)
      commands_create = true,                     -- Create commands (ConfigSource, ConfigEdit, ConfigTrust, ConfigIgnore)
      silent = false,                             -- Disable plugin messages (Config loaded/ignored)
    }
  end
}
```

## Commands

The plugin defines the commands:

- `ConfigSource` - source a config file from the current directory
- `ConfigEdit` - edit config file for from current directory
- `ConfigTrust` - trust to config file from the current directory
- `ConfigIgnore` - ignore a config file from the current directory

## Events

The plugin sends event `User ConfigLoaded` after loading configuration.
So users may bind `autocmd` to the event:

```vim
autocmd User ConfigFinished lua my_custom_function()
```
