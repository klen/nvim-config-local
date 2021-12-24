local HashMap = require "config-local.hashmap"
local Notifier = require "config-local.notify"
local utils = require "config-local.utils"
local api = vim.api
local hashmap, notifier
local M = {
  -- Default config
  config = {
    config_files = { ".vimrc.lua", ".vimrc" },
    hashfile = vim.fn.stdpath "data" .. "/config-local",
    autocommands_create = true,
    commands_create = true,
    silent = false,
  },
}

---Forget a config file
---
function M.forget()
  local filename = vim.fn.expand "%:p"
  hashmap:write(filename, nil)
end

---Confirm a config file on save
---
function M.confirm()
  local filename = vim.fn.expand "%:p"
  local state = hashmap:verify(filename)
  if state ~= "t" then
    local choice = notifier:confirm(
      "Do you want to mark this config as trusted: " .. filename .. "?",
      "&Yes\n&No"
    )
    if choice == 1 then
      return M.trust(filename)
    end
  end
end

---Ignore local configuration
---
--- @param filename string: a file name
function M.ignore(filename)
  local rc_files = M.config.config_files
  filename = filename or utils.lookup(vim.fn.expand "%:p:h", rc_files)
  if not filename then
    return notifier:notify("Config file doesn't found: " .. table.concat(rc_files, ","), 4)
  end
  hashmap:write(filename, "!")
  notifier:notify('Config file "' .. filename .. '" marked as ignored', 3)
end

---Edit local configuration
---
--- @param filename string: a file name
function M.edit(filename)
  local rc_files = M.config.config_files
  filename = filename or utils.lookup(vim.fn.expand "%:p:h", rc_files) or rc_files[0]
  api.nvim_command("edit " .. filename)
end

---Mark the given filename as trusted
---
--- @param filename string: a file name
function M.trust(filename)
  if not utils.contains(M.config.config_files, vim.fn.fnamemodify(filename, ":t")) then
    return utils:notify('Unsupported config filetype: "' .. filename .. '"', 4)
  end
  hashmap:write(filename, hashmap:checksum(filename))
  notifier:notify('Config file "' .. filename .. '" marked as trusted')
end

---Load config if it exist in the current directory
---
function M.source()
  local filename = utils.lookup(vim.fn.expand "%:p:h", M.config.config_files)
  if not filename then
    return
  end
  local verify = hashmap:verify(filename)

  -- Ignore the config
  if verify == "i" then
    return notifier:onotify('File "' .. filename .. '" is ignored')
  end

  -- Verify the config
  if verify == "u" then
    local msg = 'Unknown config file found: "' .. vim.fn.fnamemodify(filename, ":t:r") .. '"'
    local choice = notifier:confirm(msg, "&skip\n&open\n&ignore\n&trust")
    -- Edit config
    if choice == 2 then
      return M.edit(filename)
    end
    -- Mark the config as ignore
    if choice == 3 then
      return M.ignore(filename)
    end
    -- Mark the config as trusted
    if choice == 4 then
      return M.trust(filename)
    end
    -- Read the config
  else
    api.nvim_command("source " .. filename)
    notifier:onotify('Config file loaded: "' .. vim.fn.fnamemodify(filename, ":t:r") .. '"')
  end
end

-- Setup the plugin
---
function M.setup(cfg)
  -- Update config
  if cfg ~= nil then
    M.config = vim.tbl_deep_extend("force", M.config, cfg)
  end

  local config = M.config
  local rc_files = M.config.config_files

  -- Initialize tools
  hashmap = HashMap:init(config.hashfile)
  notifier = Notifier:init(config.silent)

  if #rc_files == 0 then
    return notifier:notify('Invalid config: "config_files" is empty', 4)
  end

  if M.config.commands_create then
    api.nvim_command "command ConfigEdit lua require'config-local'.edit()<CR>"
    api.nvim_command "command ConfigSource lua require'config-local'.source()<CR>"
    api.nvim_command "command ConfigTrust lua require'config-local'.trust(vim.fn.expand('%:p'))<CR>"
    api.nvim_command "command ConfigIgnore lua require'config-local'.ignore()<CR>"
  end

  if M.config.autocommands_create then
    utils.augroup("config-local", {
      -- Source local configs
      "DirChanged global nested lua require'config-local'.source()",
      "VimEnter * nested lua require'config-local'.source()",
      -- Confirm local configs
      "BufWritePost " .. table.concat(rc_files, ",") .. " lua require'config-local'.confirm()",
      -- Fix filetype for '.vimrc.lua'
      utils.contains(rc_files, ".vimrc.lua") and "BufRead .vimrc.lua set filetype=lua",
    })
  end
end

return M
