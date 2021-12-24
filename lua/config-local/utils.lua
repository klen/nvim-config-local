local api = vim.api

return {

  ---VIM augroup command helper
  ---
  augroup = function(group_name, definitions)
    api.nvim_command("augroup " .. group_name)
    api.nvim_command "autocmd!"
    for _, def in ipairs(definitions) do
      if def then
        api.nvim_command("autocmd " .. def)
      end
    end
    api.nvim_command "augroup END"
  end,

  ---Lookup for config files in the given directory
  ---
  ---@returns string (optional) is the file trusted
  lookup = function(dir_path, filenames)
    local file
    for _, filename in ipairs(filenames) do
      file = io.open(dir_path .. "/" .. filename, "r")
      if file ~= nil then
        file:close()
        return dir_path .. "/" .. filename
      end
    end
    return nil
  end,

  ---Check for the given table contains an element
  ---
  ---@returns boolean is the table contains the value
  contains = function(t, el)
    for _, value in ipairs(t) do
      if value == el then
        return true
      end
    end
    return false
  end,
}
