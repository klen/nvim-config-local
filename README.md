<img src="https://neovim.io/logos/neovim-mark-flat.png" align="right" width="144" />

# nvim-config-local 2.1.0

Secure load local config files.

[![tests](https://github.com/klen/nvim-config-local/actions/workflows/tests.yml/badge.svg)](https://github.com/klen/nvim-config-local/actions/workflows/tests.yml)
[![Awesome Neovim](https://awesome.re/badge-flat.svg)](https://github.com/rockerBOO/awesome-neovim)

Vim provides a feature called `exrc`, which allows to use config files that are
local to the current working directory. However, unconditionally sourcing
whatever files we might have in our current working directory can be
potentially dangerous. ~~Because of that, neovim has disabled the feature.~~
(reenabled from version 0.9) The plugin tries to solve this issue by keeping
track of file hashes and allowing only trusted files to be sourced.

## Usage

When the plugin detects a new config file, it will ask what do you want to do
with it:

```
[config-local]: Unknown config file found: ".nvim.lua"
[i]gnore, (v)iew, (d)eny, (a)llow:
```

You can either `i`gnore this file for now, `v`iew it to see if it doesn't contain
anything malicious, `d`eny sourcing the file so `config-local` won't ask you about it
again, or `a`llow (mark it allowed) sourcing it right away.

To manually mark file as trusted, open the config file with `:edit .nvim.lua` or
`:ConfigEdit` and save it. You will be asked to trust the current config file.

File has to be marked as trusted each time its contents or path changes.

## Install

with [packer](https://github.com/wbthomason/packer.nvim):

```lua

use {
  "klen/nvim-config-local",
  config = function()
    require('config-local').setup {
      -- Default options (optional)

      -- Config file patterns to load (lua supported)
      config_files = { ".nvim.lua", ".nvimrc", ".exrc" },

      -- Where the plugin keeps files data
      hashfile = vim.fn.stdpath("data") .. "/config-local",

      autocommands_create = true, -- Create autocommands (VimEnter, DirectoryChanged)
      commands_create = true,     -- Create commands (ConfigLocalSource, ConfigLocalEdit, ConfigLocalTrust, ConfigLocalDeny)
      silent = false,             -- Disable plugin messages (Config loaded/denied)
      lookup_parents = false,     -- Lookup config files in parent directories
    }
  end
}
```

## Commands

The plugin defines the commands:

- `ConfigLocalSource` - Source config file from the current working directory
- `ConfigLocalEdit` - Edit (create) config file for the current working directory
- `ConfigLocalTrust` - Add config file for the current working directory to trusted files.
- `ConfigLocalDeny - Add config file for the current working directory to denied files.

## Events

The plugin sends event `User ConfigLocalLoaded` after loading configuration.
So users may bind `autocmd` to the event:

```vim
autocmd User ConfigLocalFinished lua my_custom_function()
```
