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
