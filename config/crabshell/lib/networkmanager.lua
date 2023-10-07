local gio = crabshell.gio
local glib = crabshell.glib
local utils = crabshell.utils

local stringutil = require("lib.stringutil")

---@param str string
---@param separator string
---@param withpattern? boolean
local function split_columns(str)
    local result = {}
    local current_pos = 1

    for i = 1, #str do
        local start_pos, end_pos = str:find("[^\\]:", current_pos)
        if not start_pos then break end

        result[i] = str:sub(current_pos, start_pos)
        current_pos = end_pos + 1
    end

    result[#result + 1] = str:sub(current_pos)

    return result
end

---@alias NetworkManagerState `"connected (site only)"`|`"connected"`|`"connecting"`|`"disconnecting"`|`"disconnected"`
---@alias NetworkManagerInterfaceState `"connecting"`|`"connected"`|`"deactivating"`|`"disconnected"`
---@enum NetworkManagerEventType
local NetworkManagerEventType = {
    Interface = 0,
    State = 1,
    InterfaceConnection = 2,
    PrimaryConnection = 3,
}


---@alias NetworkManagerCallback fun(type: NetworkManagerEventType):nil

---@class NetworkManagerConnection
---@field ssid string

---@class NetworkManagerAP
---@field ssid string
---@field signal integer
---@field rate string
---@field active boolean

---@class NetworkManagerInterface
---@field state NetworkManagerInterfaceState
---@field extra_info? string
---@field connection? NetworkManagerConnection

---@class NetworkManagerService
---@field state NetworkManagerState
---@field interfaces table<string, NetworkManagerInterface>
---@field primary_connection? NetworkManagerConnection
---@field primary_interface? string
---@field callbacks NetworkManagerCallback[]
local NetworkManagerService = {}
NetworkManagerService.__index = NetworkManagerService

---@return NetworkManagerService
function NetworkManagerService.new()
    local self = setmetatable({ state = "connected", interfaces = {}, callbacks = {} },
        NetworkManagerService)

    local ctx = glib.MainContext.default()

    local g_proc = gio.Subprocess.new({ "nmcli", "-t", "-f", "STATE", "g" }, { stdout_pipe = true })
    ctx:spawn_local(function()
        local stdout = g_proc:communicate()
        if not stdout then return end

        stdout = stdout:gsub("\n$", "")
        ---@cast stdout NetworkManagerState
        self.state = stdout

        self:emit(NetworkManagerEventType.State)
    end)

    local d_proc = gio.Subprocess.new({ "nmcli", "-t", "-f", "TYPE,DEVICE,STATE,CONNECTION", "d" },
        { stdout_pipe = true })
    ctx:spawn_local(function()
        local stdout = d_proc:communicate()
        if not stdout then return end

        local is_first_line = false
        for line in stdout:gmatch("[^\n]+") do
            local type, iface, state, conn_ssid = unpack(split_columns(line, "[^\\]:", true))
            if not iface then break end
            if type == "wifi" then
                ---@cast iface string
                ---@cast state NetworkManagerInterfaceState
                ---@cast conn_ssid string

                ---@type NetworkManagerConnection
                local connection = {
                    ssid = conn_ssid,
                }

                self.interfaces[iface] = {
                    state = state,
                    connection = connection
                }

                -- TODO: What if there is no connection?
                -- Assume first line is the primary connection
                if state == "connected" and not is_first_line then
                    self.primary_interface = iface
                    self.primary_connection = connection
                end

                is_first_line = true
            end
        end

        self:emit(NetworkManagerEventType.Interface)
        self:emit(NetworkManagerEventType.PrimaryConnection)
    end)

    local NM_IFACE_RE = [[(?x)
        ^([a-z0-9]+?): # Iface
        \s
        (connecting|connected|deactivating|disconnected) # State
        (?:\s\(([a-zA-Z0-9\s]+?)\))? # Extra info
    ]]

    local NM_STATE_RE = [[(?x)
        ^Networkmanager
        \s is \s now \s in \s the \s
        '(connected\s\(site\sonly\)|connected|connecting|disconnecting|disconnected)' # State
    ]]

    local NM_IFACE_CONN_RE = [[(?x)
            ^([a-z0-9]+?): # Iface
            \s using \s connection \s
            '(.+?)' # Connection
    ]]

    local NM_PRIMARY_CONN_RE = [[(?x)
        '(.+?)' # Connection
        \s is \s now \s the \s primary \s connection
    ]]

    local proc = gio.Subprocess.new({ "nmcli", "-c", "no", "monitor" }, { stdout_pipe = true })
    ctx:spawn_local(function()
        local buffer = proc:stdout():into_async_buf_read(64)

        local iface_re = utils.Regex.new(NM_IFACE_RE)
        local state_re = utils.Regex.new(NM_STATE_RE)
        local iface_conn_re = utils.Regex.new(NM_IFACE_CONN_RE)
        local primary_conn_re = utils.Regex.new(NM_PRIMARY_CONN_RE)
        while true do
            local line = buffer:read_line(64)

            local match = iface_re:captures(line)
            if match then
                local iface = match[2].str
                local state = match[3].str
                ---@cast state NetworkManagerInterfaceState
                local extra_info = match[4]

                local interface = self.interfaces[iface]
                if not interface then
                    interface = {
                        state = state,
                        extra_info = extra_info and extra_info.str
                    }

                    self.interfaces[iface] = interface
                else
                    interface.state = state
                    interface.extra_info = extra_info and extra_info.str
                end

                if state == "disconnected" then
                    interface.connection = nil
                    if self.primary_interface == iface then
                        self.primary_connection = nil
                        self.primary_interface = nil
                        self:emit(NetworkManagerEventType.PrimaryConnection)
                    end
                end

                self:emit(NetworkManagerEventType.Interface)

                goto skip
            end

            match = state_re:captures(line)
            if match then
                local state = match[2].str

                ---@cast state NetworkManagerState
                self.state = state

                self:emit(NetworkManagerEventType.State)

                goto skip
            end

            match = iface_conn_re:captures(line)
            if match then
                local iface = match[2].str
                local conn = match[3].str

                local interface = self.interfaces[iface]
                interface.connection = { ssid = conn }

                self:emit(NetworkManagerEventType.InterfaceConnection)

                goto skip
            end

            match = primary_conn_re:captures(line)
            if match then
                local conn = match[2].str

                self.primary_connection = { ssid = conn }
                for iface, data in pairs(self.interfaces) do
                    if data.connection == conn then
                        self.primary_interface = iface
                        break
                    end
                end

                self:emit(NetworkManagerEventType.PrimaryConnection)

                goto skip
            end

            if line:find("There's no primary connection", 1, true) then
                self.primary_connection = nil

                self:emit(NetworkManagerEventType.PrimaryConnection)

                goto skip
            end

            ::skip::
        end
    end)

    return self
end

---@param callback NetworkManagerCallback
function NetworkManagerService:subscribe(callback)
    self.callbacks[#self.callbacks + 1] = callback
end

---@package
---@param type NetworkManagerEventType
function NetworkManagerService:emit(type)
    local callbacks = self.callbacks
    for i = 1, #callbacks do
        callbacks[i](type)
    end
end

---@async
---@param rescan boolean?
---@return NetworkManagerAP[]?
function NetworkManagerService:get_access_points(rescan)
    rescan = rescan or false

    local proc = gio.Subprocess.new(
        { "nmcli", "-t", "-f", "SSID,SIGNAL,RATE,ACTIVE", "d", "wifi", "list", "--rescan", rescan and "yes" or "no" },
        { stdout_pipe = true })
    local stdout = proc:communicate()
    if not stdout then return nil end

    ---@type NetworkManagerAP[]
    local aps = {}
    for line in stdout:gmatch("[^\n]+") do
        local cols = split_columns(line, "[^\\]:", true)
        local ssid, signal, rate, active = cols[1], cols[2], cols[3], cols[4]
        --     TODO:
        if ssid and active then
            ---@cast ssid string
            ---@cast signal string
            ---@cast active string

            aps[#aps + 1] = {
                ssid = ssid,
                ---@diagnostic disable-next-line: assign-type-mismatch
                signal = tonumber(signal),
                rate = rate,
                active = active == "yes"
            }
        end
    end

    return aps
end

---@async
---@param ssid string
---@param rescan boolean?
---@return integer?
function NetworkManagerService:get_signal_strength(ssid, rescan)
    rescan = rescan or false

    local aps = self:get_access_points(rescan)
    if not aps then return nil end

    -- Prefer active connections
    table.sort(aps, function(a)
        return a.active
    end)

    for i = 1, #aps do
        local ap = aps[i]
        if ap.ssid == ssid then
            return ap.signal
        end
    end

    return nil
end

---@return NetworkManagerConnection[]?
function NetworkManagerService:get_known_wifi_connections()
    local proc = gio.Subprocess.new(
        { "nmcli", "-t", "-f", "NAME,TYPE,ACTIVE", "c" },
        { stdout_pipe = true })
    local stdout = proc:communicate()
    if not stdout then return nil end

    ---@type NetworkManagerConnection[]
    local connections = {}
    for line in stdout:gmatch("[^\n]+") do
        -- TODO:
        ---@diagnostic disable-next-line: unused-local
        local name, type, active = unpack(split_columns(line, "[^\\]:", true))
        if type == "802-11-wireless" then
            ---@cast name string
            ---@cast type string
            ---@cast active string

            connections[#connections + 1] = {
                ssid = name,
            }
        end
    end

    return connections
end

return {
    NetworkManagerEventType = NetworkManagerEventType,
    NetworkManagerService = NetworkManagerService
}
