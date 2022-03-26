local HashMap = {}
HashMap.__index = HashMap

---Split line helper
local function split(line)
  local s, e = line:find "\t"
  if s and e then
    return line:sub(1, s - 1), line:sub(e + 1)
  end
  return "", nil
end

--Initialize hash helper
---@param filename string: a filename with hashes
---@returns HashMap
function HashMap:init(filename)
  self = {}
  setmetatable(self, HashMap)
  self.data = nil
  self.filename = filename
  return self
end

---Load hash data
function HashMap:load()
  self.data = {}
  local file = io.open(self.filename, "r")
  if file then
    for line in file:lines() do
      local filename, checksum = split(line)
      self.data[filename] = checksum
    end
    file:close()
  end
end

---Write file information
---@param filename string: a filename to save
---@param checksum string: (optional) a checksum to save
function HashMap:write(filename, checksum)
  if self.data == nil then
    self:load()
  end
  local file = io.open(self.filename, "w")
  if file then
    self.data[filename] = checksum
    for filename_, checksum_ in pairs(self.data) do
      file:write(filename_ .. "\t" .. checksum_ .. "\n")
    end
    file:close()
  end
end

--Calculate a checksum
---@param filename string: a filename
---@returns string (optional): a checksum
function HashMap:checksum(filename)
  local file = io.open(filename, "r")
  if file then
    local checksum = vim.fn.sha256(file:read "*a")
    file:close()
    return checksum
  end
end

---Verify a filename
---@param filename string: a filename
---@returns string: a status (i|u|t)
function HashMap:verify(filename)
  if self.data == nil then
    self:load()
  end
  local checksum = self.data[filename]
  if checksum == "!" then
    return "i"
  end
  if not checksum or (checksum ~= self:checksum(filename)) then
    return "u"
  end
  return "t"
end

function HashMap:trust(filename)
  return self:write(filename, self:checksum(filename))
end

function HashMap:reset()
  local file = io.open(self.filename, "w")
  file:close()
end

return HashMap
