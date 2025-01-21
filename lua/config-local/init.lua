local HashMap = require "config-local.hashmap"
local Notifier = require "config-local.notify"
local utils = require "config-local.utils"
local api = vim.api
local hashmap, notifier
local findfile = vim.fn.findfile
local M = {
  -- Default config
  config = {
    config_files = { ".nvim.lua", ".nvimrc", ".exrc" },
    hashfile = vim.fn.stdpath "data" .. "/config-local",
    autocommands_create = true,
    commands_create = true,
    silent = false,
    lookup_parents = false,
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

---Deny local configuration
---
--- @param filename string: a file name
function M.deny(filename)
  filename = filename or M.lookup()
  if not filename then
    return notifier:notify(
      "Config file doesn't found: " .. table.concat(M.config.config_files, ","),
      4
    )
  end
  hashmap:write(filename, "!")
  notifier:notify('Config file "' .. filename .. '" marked as denied', 3)
end

---Edit local configuration
---
--- @param filename string: a file name
function M.edit(filename)
  filename = filename or M.lookup() or M.config.config_files[1]
  api.nvim_command("edit " .. filename)
end

---Mark the given filename as trusted
---
--- @param filename string: a file name
function M.trust(filename)
  if not utils.contains_filename(M.config.config_files, filename) then
    return notifier:notify('Unsupported config filetype: "' .. filename .. '"', 4)
  end
  hashmap:trust(filename)
  notifier:notify('Config file "' .. filename .. '" marked as trusted')
  M.read(filename)
end

---Read the given filename
function M.read(filename)
  api.nvim_command("source " .. filename)
  notifier:onotify('Config file loaded: "' .. vim.fn.fnamemodify(filename, ":~:.") .. '"')
end

---Look for config files
function M.lookup()
  local config = M.config
  local files = config.config_files
  for _, filename in ipairs(files) do
    filename = findfile(filename, ".")
    if filename ~= "" then
      return vim.fn.fnamemodify(filename, ":p")
    end
  end
  if config.lookup_parents then
    for _, filename in ipairs(files) do
      filename = findfile(filename, ".;")
      if filename ~= "" then
        return vim.fn.fnamemodify(filename, ":p")
      end
    end
  end
end

---Load config if it exist in the current directory
---
function M.source()
  local filename = M.lookup()
  if filename then
    local verify = hashmap:verify(filename)

    -- Read the config
    if verify == "t" then
      M.read(filename)

      -- Verify the config
    elseif verify == "u" then
      local msg = 'Unknown config file found: "' .. vim.fn.fnamemodify(filename, ":~:.") .. '"'
      local choice = notifier:confirm(msg, "&ignore\n&view\n&deny\n&allow")

      -- Edit config
      if choice == 2 then
        M.edit(filename)

        -- Mark the config as denied
      elseif choice == 3 then
        M.deny(filename)

        -- Mark the config as trusted
      elseif choice == 4 then
        M.trust(filename)
      end

      -- Deny the config
    else
      notifier:onotify('File "' .. filename .. '" is denied')
    end
  end
  api.nvim_command "doautocmd User ConfigLocalFinished"
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
    api.nvim_command "command! ConfigLocalEdit lua require'config-local'.edit()<CR>"
    api.nvim_command "command! ConfigLocalSource lua require'config-local'.source()<CR>"
    api.nvim_command "command! ConfigLocalTrust lua require'config-local'.trust(vim.fn.expand('%:p'))<CR>"
    api.nvim_command "command! ConfigLocalDeny lua require'config-local'.deny()<CR>"
  end

  if M.config.autocommands_create then
    local au = vim.api.nvim_create_autocmd
    local augroup = vim.api.nvim_create_augroup("config-local", { clear = true })

    -- Source local configs
    au("VimEnter", {
      group = augroup,
      desc = "Source local configs",
      pattern = "*",
      nested = true,
      callback = M.source,
    })

    au("DirChanged", {
      group = augroup,
      desc = "Source local configs",
      callback = M.source,
    })

    -- Confirm local configs
    au("BufWritePost", {
      group = augroup,
      desc = "Confirm local configs",
      pattern = table.concat(
        utils.map(rc_files, function(f)
          return "**/" .. f
        end),
        ","
      ),
      nested = true,
      callback = M.confirm,
    })

    if utils.contains(rc_files, ".vimrc.lua") then
      au("BufRead", {
        group = augroup,
        desc = 'Fix filetype for ".vimrc.lua"',
        pattern = ".vimrc.lua",
        nested = true,
        callback = function()
          api.nvim_command "set filetype=lua"
        end,
      })
    end
  end
end

return M
