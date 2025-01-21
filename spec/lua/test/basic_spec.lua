local helpers = require "spec.lua.helpers"
local hashmap = helpers.hashmap
local fixtures = helpers.fixtures

describe("config-local.plugin", function()
  after_each(helpers.after_each)
  before_each(helpers.before_each)

  it("test setup", function()
    local plugin = require "config-local"
    assert.truthy(plugin.config)
    assert.equal(plugin.config.silent, true)
  end)

  it("test commands", function()
    assert.is_true(vim.fn.exists ":ConfigLocalSource" > 0)
    assert.is_true(vim.fn.exists ":ConfigLocalEdit" > 0)
    assert.is_true(vim.fn.exists ":ConfigLocalTrust" > 0)
    assert.is_true(vim.fn.exists ":ConfigLocalDeny" > 0)
  end)
end)

describe("config-local.basic", function()
  after_each(helpers.after_each)
  before_each(helpers.before_each)

  it("test trust", function()
    local plugin = require "config-local"
    plugin.trust(fixtures .. ".vimrc.lua")
    assert.equal(hashmap:verify(fixtures .. ".vimrc.lua"), "t")
  end)

  it("test load", function()
    hashmap:trust(fixtures .. ".vimrc.lua")
    vim.cmd("cd " .. fixtures)
    assert.equal(vim.g.config_test, ".vimrc.lua")
  end)

  it("test subfolder load", function()
    local plugin = require "config-local"
    plugin.setup { lookup_parents = true }

    assert.equal(vim.g.config_test, nil)
    hashmap:trust(fixtures .. ".vimrc.lua")
    vim.cmd("cd " .. fixtures .. "subfolder")
    assert.equal(vim.g.config_test, ".vimrc.lua")
  end)

  it("test config from subfolder", function()
    local plugin = require "config-local"
    plugin.setup { config_files = { "rc/config.lua" } }

    hashmap:trust(fixtures .. "rc/config.lua")
    vim.cmd("cd " .. fixtures)
    assert.equal(vim.g.config_test, "rc/config.lua")
  end)
end)

describe("config-local.hashmap", function()
  local filename = fixtures .. "dummy.txt"

  after_each(helpers.after_each)
  before_each(helpers.before_each)

  it("test unknown", function()
    assert.equal(hashmap:verify(filename), "u")
  end)

  it("test trust", function()
    hashmap:trust(filename)
    assert.equal(hashmap:verify(filename), "t")
    hashmap:write(filename, hashmap:checksum(fixtures .. ".vimrc.lua"))
    assert.equal(hashmap:verify(filename), "u")
  end)

  it("test deny", function()
    hashmap:write(filename, "!")
    assert.equal(hashmap:verify(filename), "i")
  end)
end)
