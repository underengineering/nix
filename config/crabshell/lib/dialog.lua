local gio = crabshell.gio
local utils = crabshell.utils

---@alias DialogType `"prompt"`|`"password"`

---@alias DialogDataPrompt nil

---@class DialogDataPassword
---@field password string
---
---@class DialogDataError
---@field reason? string
---@field extra? table

---@alias DialogData DialogDataPrompt|DialogDataPassword|DialogDataError|nil

---@class DialogResult
---@field success boolean
---@field data DialogData

---@class DialogResultPrompt
---@field success boolean

---@class DialogResultPassword
---@field success boolean
---@field data DialogDataPassword

local _M = {}


--[[ ---@class PasswordCacheKey
---@field key string
---@field private on_invalidation? fun():nil
_M.PasswordCacheKey = {}
_M.PasswordCacheKey.__index = _M.PasswordCacheKey

function _M.PasswordCacheKey.new(key)
    return setmetatable({ key = key }, _M.PasswordCacheKey)
end

function _M.PasswordCacheKey:invalidate()
    if self.on_invalidation then
        self.on_invalidation()
    end
end

---@package
---@param callback fun():nil
function _M.PasswordCacheKey:connect_invalidated(callback)
    self.on_invalidation = callback
end

local PASSWORD_CACHE = {} ]]

---@async
---@param title string
---@return DialogResultPrompt?
function _M.dialog_prompt(title)
    local proc = gio.Subprocess.new(
        { "crabshell", "-c", "dialog.lua", title, "prompt" },
        { stdout_pipe = true })
    local stdout = proc:communicate()
    if not stdout then return nil end

    return utils.json.from_str(stdout)
end

---@async
---@param title string
---@return DialogResultPassword?
function _M.dialog_password(title)
    local proc = gio.Subprocess.new(
        { "crabshell", "-c", "dialog.lua", title, "password" },
        { stdout_pipe = true })
    local stdout = proc:communicate()
    if not stdout then return nil end

    return utils.json.from_str(stdout)
end

return _M
