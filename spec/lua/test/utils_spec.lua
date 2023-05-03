local utils = require "config-local.utils"

describe("config-local.utils", function()
  it("test basic", function()
    assert.truthy(utils.contains)
    assert.truthy(utils.contains_filename)
  end)

  it("test contains_filename", function()
    local files = { ".vimrc.lua", ".vimrc", "rc/config.lua" }
    assert.is_true(utils.contains_filename(files, ".vimrc.lua"))
    assert.is_true(utils.contains_filename(files, ".vimrc"))
    assert.is_false(utils.contains_filename(files, "unknown"))
    assert.is_true(utils.contains_filename(files, "some/.vimrc"))
    assert.is_false(utils.contains_filename(files, "some/unknown"))
    assert.is_true(utils.contains_filename(files, "rc/config.lua"))
    assert.is_true(utils.contains_filename(files, "some/rc/config.lua"))
    assert.is_false(utils.contains_filename(files, "some/rc/config2.lua"))
  end)
end)
