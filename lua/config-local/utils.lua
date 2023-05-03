local api = vim.api

---Check for the given table contains an element
---
---@returns boolean is the table contains the value
local contains = function(t, el)
  for _, value in ipairs(t) do
    if value == el then
      return true
    end
  end
  return false
end

return {

  contains = contains,

  map = function(t, f)
    local t1 = {}
    local t_len = #t
    for i = 1, t_len do
      t1[i] = f(t[i])
    end
    return t1
  end,

  contains_filename = function(files, path)
    if path ~= "" then
      if contains(files, vim.fn.fnamemodify(path, ":t")) then
        return true
      end
      local fullpath = vim.fn.fnamemodify(path, ":p")
      for _, p in ipairs(files) do
        if fullpath:sub(-#p) == p then
          return true
        end
      end
    end
    return false
  end,
}
