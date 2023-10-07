local dialog = require("lib.dialog")
local networkmanager = require("lib.networkmanager")
local NetworkManagerEventType = networkmanager.NetworkManagerEventType
local NetworkManagerService = networkmanager.NetworkManagerService

local gio = crabshell.gio
local glib = crabshell.glib
local gtk = crabshell.gtk
local pulseaudio = crabshell.pulseaudio
local sysinfo = crabshell.sysinfo
local utils = crabshell.utils

---@alias PulseaudioCallback fun(facility: Facility, op: Operation, index: integer):nil

---@class PulseaudioService
---@field context Context
---@field connected boolean
---@field default_sink SinkInfo?
---@field private callbacks PulseaudioCallback[]
local PulseaudioService = {}
PulseaudioService.__index = PulseaudioService

---@param callback PulseaudioCallback
function PulseaudioService:subscribe(callback)
    self.callbacks[#self.callbacks + 1] = callback
end

---@param facility Facility
---@param op Operation
---@param index integer
function PulseaudioService:emit(facility, op, index)
    local callbacks = self.callbacks
    for i = 1, #callbacks do
        callbacks[i](facility, op, index)
    end
end

---@param mainloop Mainloop
function PulseaudioService.new(mainloop)
    local context = pulseaudio.Context.new(mainloop, "sidebar")
    context:connect()

    local self = setmetatable({
        context = context,
        connected = false,
        callbacks = {}
    }, PulseaudioService)

    ---@param facility Facility
    ---@param op Operation
    ---@param index integer
    local function on_event(facility, op, index)
        if op == pulseaudio.Operation.Removed and self.default_sink then
            -- If the removed sink id is the current sink id
            if index == self.default_sink.index then
                -- Get info about new sink
                context:get_server_info(function(info)
                    context:get_sink_info_by_name(info.default_sink_name, function(sink)
                        self.default_sink = sink
                        self:emit(facility, op, index)
                    end)
                end)
            end

            -- Cannot get sink info after it's removal
            return
        end

        context:get_sink_info_by_index(index, function(sink)
            self.default_sink = sink
            self:emit(facility, op, index)
        end)
    end

    local function on_context_ready()
        context:get_server_info(function(info)
            context:get_sink_info_by_name(info.default_sink_name, function(sink)
                self.default_sink = sink
                self:emit(pulseaudio.Facility.Sink, pulseaudio.Operation.New, sink.index)
            end)
        end)

        context:subscribe({ sink = true }, function()
            context:set_subscribe_callback(on_event)
        end)
    end

    context:set_state_callback(function()
        local state = context:get_state()
        if state == pulseaudio.State.Ready then
            self.connected = true
            on_context_ready()
            self:emit(pulseaudio.Facility.Client, pulseaudio.Operation.New, -1)
        elseif state == pulseaudio.State.Failed or state == pulseaudio.State.Terminated or state == pulseaudio.State.Unconnected then
            self.connected = false
            self:emit(pulseaudio.Facility.Client, pulseaudio.Operation.Removed, -1)
        end
    end)

    return self
end

---@class ChevronButton
---@field widget Box
---@field button Button
---@field chevron Button
local ChevronButton = {}
ChevronButton.__index = ChevronButton

---@class ToggleButtonManual
---@field widget Button
---@field private _is_active boolean
local ToggleButtonManual = {}
ToggleButtonManual.__index = ToggleButtonManual

function ToggleButtonManual:set_active(is_active)
    self._is_active = is_active
    if is_active then
        self.widget:add_css_class("toggled")
    else
        self.widget:remove_css_class("toggled")
    end
end

function ToggleButtonManual:is_active()
    return self._is_active
end

---@return ToggleButtonManual
function ToggleButtonManual.with_label(label)
    local button = gtk.Button.with_label(label)
    button:set_css_class("toggle")

    return setmetatable({ widget = button, _is_active = false }, ToggleButtonManual)
end

---@param label string
function ChevronButton.new(label)
    local container = gtk.Box.new(gtk.Orientation.Horizontal)
    container:set_css_class("chevron-button")

    local button = gtk.Button.with_label(label)
    button:set_css_class("button")
    button:set_hexpand(true)

    local chevron = gtk.Button.with_label("󰅂")
    chevron:set_css_class("chevron")

    container:append(button:upcast())
    container:append(chevron:upcast())
    return setmetatable({ widget = container, button = button, chevron = chevron }, ChevronButton)
end

---@param enabled boolean
---@param signal integer
local function get_wifi_icon(enabled, signal)
    local WIFI_ICONS = { "󰤯", "󰤟", "󰤢", "󰤥", "󰤨" }
    local WIFI_DISABLED_ICON = "󰤭"

    if not enabled then
        return WIFI_DISABLED_ICON
    end

    local idx = math.floor(signal / 100 * (#WIFI_ICONS - 1)) + 1
    return WIFI_ICONS[idx]
end

---@param networkmanager_service NetworkManagerService
local function build_quick_options(networkmanager_service)
    local ctx = glib.MainContext.default()

    local container = gtk.Grid.new()
    container:set_css_class("grid")
    container:set_row_spacing(4)
    container:set_column_spacing(4)

    local wifi = ChevronButton.new("󰤢 Wi-Fi")
    wifi.widget:set_hexpand(true)
    wifi.button:connect_clicked(function()
        local command = networkmanager_service.state == "disconnected" and "on" or "off"
        wifi.widget:set_sensitive(false)
        ctx:spawn_local(function()
            local proc = gio.Subprocess.new({ "nmcli", "r", "wifi", command })
            proc:wait()
            wifi.widget:set_sensitive(true)
        end)
    end)

    local UPDATE_ON = {
        [NetworkManagerEventType.State] = true,
        [NetworkManagerEventType.PrimaryConnection] = true,
    }
    networkmanager_service:subscribe(function(type)
        if UPDATE_ON[type] then
            local primary_conn = networkmanager_service.primary_connection
            if primary_conn then
                local enabled = networkmanager_service.state == "connected" or
                    networkmanager_service.state == "connected (site only)"
                local ssid = primary_conn.ssid
                local signal = networkmanager_service:get_signal_strength(ssid) or 100
                local icon = get_wifi_icon(enabled, signal)
                wifi.button:set_label(("%s %s"):format(icon, primary_conn.ssid))
            else
                wifi.button:set_label("󰤭 Wi-Fi")
            end
        end
    end)
    container:attach(wifi.widget:upcast(), 0, 0)

    local bluetooth = ToggleButtonManual.with_label("󰂯 Bluetooth")
    bluetooth.widget:set_hexpand(true)
    bluetooth.widget:connect_clicked(function()
        bluetooth.widget:set_sensitive(false)
        ctx:spawn_local(function()
            local tbl = dialog.dialog_password("This operation requires authentication.")
            if not tbl or not tbl.success then
                bluetooth.widget:set_sensitive(true)
                return
            end

            local active = not bluetooth:is_active()
            local command = active and "unblock" or "block"

            local proc = gio.Subprocess.new({ "sudo", "-S", "rfkill", command, "1", "2" }, { stdin_pipe = true })
            proc:communicate(tbl.data.password)

            bluetooth:set_active(active)
            bluetooth.widget:set_sensitive(true)
        end)
    end)
    ctx:spawn_local(function()
        local proc = gio.Subprocess.new({ "rfkill", "-J" }, { stdout_pipe = true })
        local stdout = proc:communicate()
        if not stdout then return end

        local active = true
        local data = utils.json.from_str(stdout)
        for _, device in ipairs(data.rfkilldevices or {}) do
            if device.type == "bluetooth" and device.soft == "blocked" then
                active = false
            end
        end

        bluetooth:set_active(active)
    end)
    container:attach(bluetooth.widget:upcast(), 1, 0)

    local power_save = ToggleButtonManual.with_label("󰂐 Power save")
    power_save.widget:set_hexpand(true)
    power_save.widget:connect_clicked(function()
        power_save.widget:set_sensitive(false)
        ctx:spawn_local(function()
            local tbl = dialog.dialog_password("This operation requires authentication.")
            if not tbl or not tbl.success then
                power_save.widget:set_sensitive(true)
                return
            end

            local POWERSAVE_ON = [[
                cpupower frequency-set -g powersave
                echo "power" | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
            ]]

            local POWERSAVE_OFF = [[
                cpupower frequency-set -g performance
                echo "performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
            ]]

            local is_active = not power_save:is_active()

            local script = is_active and POWERSAVE_ON or POWERSAVE_OFF
            local proc = gio.Subprocess.new({ "sudo", "-S", "bash", "-c", script },
                { stdin_pipe = true, stdout_pipe = true, stderr_pipe = true })
            ---@diagnostic disable-next-line: unused-local
            local stdout, stderr = proc:communicate(tbl.data.password)
            if proc:exit_status() == 0 then
                power_save:set_active(is_active)
            end

            power_save.widget:set_sensitive(true)
        end)
    end)
    ctx:spawn_local(function()
        local file = gio.File.for_path("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor")
        local stream = file:read()
        local content = stream:read(64)
        local is_active = content:find("powersave", 1, true) ~= nil
        power_save:set_active(is_active)
    end)
    container:attach(power_save.widget:upcast(), 0, 1)

    return { widget = container, wifi = wifi, bluetooth = bluetooth, power_save = power_save }
end

---@param value_from number
---@param value_to number
---@param factor number
local function moving_average(value_from, value_to, factor)
    return value_from * (1 - factor) + value_to * factor
end

local function build_battery_info()
    local ctx = glib.MainContext.default()

    local container = gtk.Box.new(gtk.Orientation.Vertical)
    container:set_css_class("group-box")

    local label = gtk.Label.new("󰁹 Battery")
    label:set_halign(gtk.Align.Start)

    local info = gtk.Label.new()
    local prev_status
    local remaining_time_avg = 0
    ctx:spawn_local(function()
        local MAIN_BATTERY = "BAT0"

        while true do
            local batteries = sysinfo.battery.get_batteries()
            local battery = batteries.info[MAIN_BATTERY]
            if battery then
                local status = battery.status
                if status ~= prev_status then
                    remaining_time_avg = battery.remaining_time.secs
                end

                if status == "Charging" then
                    remaining_time_avg = moving_average(remaining_time_avg, battery.remaining_time.secs, 0.8)

                    local str = os.date("󱐋 Charge in %H:%M:%S", battery.remaining_time.secs)
                    ---@cast str string
                    info:set_label(str)
                elseif status == "Discharging" then
                    remaining_time_avg = moving_average(remaining_time_avg, battery.remaining_time.secs, 0.8)

                    local str = os.date("󱐋 Discharge in %H:%M:%S %.1fW", remaining_time_avg)
                    ---@cast str string
                    info:set_label(str:format(battery.current / 10000000))
                elseif status == "Not charging" then
                    info:set_label("Not charging")
                elseif status == "Full" then
                    info:set_label("Full")
                else
                    info:set_label("Unknown")
                end

                prev_status = status
            end

            utils.sleep(5)
        end
    end)

    container:append(label:upcast())
    container:append(info:upcast())

    return container
end

---@param orientation Orientation
---@param spacing? number
---@param children Widget
local function boxed(orientation, spacing, children)
    local container = gtk.Box.new(orientation, spacing)
    for i = 1, #children do
        container:append(children[i]:upcast())
    end

    return container
end

---@param pulseaudio_service PulseaudioService
local function build_sliders(pulseaudio_service)
    local ctx = glib.MainContext.default()
    local container = gtk.Box.new(gtk.Orientation.Vertical, 4)

    ---@type Box
    local volume_container
    do
        local volume_label = gtk.Label.new("󰕾 Volume")
        volume_label:set_halign(gtk.Align.Start)

        local volume_scale = gtk.Scale.with_range(gtk.Orientation.Horizontal, 0, 100, 5)
        volume_scale:set_draw_value(true)
        volume_scale:set_sensitive(pulseaudio_service.connected)
        volume_scale:connect_value_changed(function()
            local sink = pulseaudio_service.default_sink
            if not sink then return end

            local value = volume_scale:value()

            local volume = {}
            for i = 1, #sink.volume do
                volume[i] = value / 100 * pulseaudio.Volume.NORMAL
            end

            pulseaudio_service.context:set_sink_volume_by_index(sink.index, volume)
        end)
        pulseaudio_service:subscribe(function(facility)
            if facility == pulseaudio.Facility.Client then
                volume_scale:set_sensitive(pulseaudio_service.connected)
                return
            elseif facility ~= pulseaudio.Facility.Sink then
                return
            end

            local sink = pulseaudio_service.default_sink
            if not sink then return end

            local volume_abs = sink.volume[1]
            local volume_norm = volume_abs / pulseaudio.Volume.NORMAL
            local volume = volume_norm * 100
            volume_scale:set_value(volume)
        end)

        volume_container = boxed(gtk.Orientation.Vertical, 4, { volume_label, volume_scale })
        volume_container:set_css_class("group-box")
    end

    ---@type Box
    local backlight_container
    do
        local backlight_label = gtk.Label.new("󰃟 Backlight")
        backlight_label:set_halign(gtk.Align.Start)

        local backlight_scale = gtk.Scale.with_range(gtk.Orientation.Horizontal, 0, 100, 5)
        backlight_scale:set_draw_value(true)
        backlight_scale:connect_value_changed(function()
            local value = backlight_scale:value()
            io.popen(("light -S %u"):format(value)):close()
        end)
        ctx:spawn_local(function()
            local proc = gio.Subprocess.new({ "light" }, { stdout_pipe = true })
            local stdout, _ = proc:communicate()
            local stdout_parsed = tonumber(stdout)
            if stdout_parsed then
                -- Round
                stdout_parsed = math.floor(stdout_parsed + 0.5)
                backlight_scale:set_value(stdout_parsed)
            end
            proc:wait()
        end)

        backlight_container = boxed(gtk.Orientation.Vertical, 4, { backlight_label, backlight_scale })
        backlight_container:set_css_class("group-box")
    end

    container:append(volume_container:upcast())
    container:append(backlight_container:upcast())

    return container
end

---@param networkmanager_service NetworkManagerService
local function build_wifi_list(networkmanager_service)
    local ctx = glib.MainContext.default()

    local container = gtk.Box.new(gtk.Orientation.Vertical, 4)
    container:set_css_class("wifi-container")

    ---@type Box
    local active_ap_container
    do
        local active_ap_label = gtk.Label.new("Connected to")
        active_ap_label:set_halign(gtk.Align.Start)

        local active_ap_ssid = gtk.Label.new()
        local disconnect = gtk.Button.with_label("󱐤 Disconnect")
        disconnect:connect_clicked(function()
            local primary_conn = networkmanager_service.primary_connection
            if not primary_conn then return end

            ctx:spawn_local(function()
                local proc = gio.Subprocess.new({ "nmcli", "c", "down", primary_conn.ssid })
                proc:wait()
            end)
        end)

        ---@param primary_conn? NetworkManagerConnection
        local function on_primary_conn(primary_conn)
            if primary_conn then
                local icon = get_wifi_icon(true, 100)
                active_ap_ssid:set_label(("%s %s"):format(icon, primary_conn.ssid))
                active_ap_container:set_visible(true)

                ctx:spawn_local(function()
                    local signal = networkmanager_service:get_signal_strength(primary_conn.ssid)
                    if not signal then return end

                    icon = get_wifi_icon(true, signal)
                    active_ap_ssid:set_label(("%s %s"):format(icon, primary_conn.ssid))
                end)

                disconnect:set_sensitive(true)
            else
                active_ap_container:set_visible(false)
                disconnect:set_sensitive(false)
            end
        end

        networkmanager_service:subscribe(function(type)
            if type == NetworkManagerEventType.PrimaryConnection then
                local primary_conn = networkmanager_service.primary_connection
                on_primary_conn(primary_conn)
            end
        end)

        active_ap_container = boxed(gtk.Orientation.Vertical, 4, { active_ap_label, active_ap_ssid, disconnect })
        active_ap_container:set_css_classes { "group-box", "active-ap" }
        on_primary_conn(networkmanager_service.primary_connection)
    end

    -- Buttons
    local buttons_container = gtk.Box.new(gtk.Orientation.Horizontal, 4)
    local refresh = gtk.Button.with_label("󱛄 Refresh")
    refresh:set_css_class("refresh")
    refresh:set_hexpand(true)
    refresh:set_css_class("close")

    local close = gtk.Button.with_label("󰅖 Close")
    close:set_hexpand(true)

    -- Lists
    local avail_list = gtk.Box.new(gtk.Orientation.Vertical, 4)
    avail_list:add_css_class("ap-list")

    local unavail_list = gtk.Box.new(gtk.Orientation.Vertical, 4)
    unavail_list:add_css_class("ap-list")

    -- List group containers
    ---@type Box
    local avail_container
    do
        local label = gtk.Label.new("󰤪 Available connections")
        label:set_halign(gtk.Align.Start)
        avail_container = boxed(gtk.Orientation.Vertical, 4,
            { label, avail_list })
        avail_container:set_css_class("group-box")

        -- Visibility is updated in on_refresh
        avail_container:set_visible(false)
    end

    ---@type Box
    local unavail_container
    do
        local label = gtk.Label.new("󰤪 Unknown connections")
        label:set_halign(gtk.Align.Start)
        unavail_container = boxed(gtk.Orientation.Vertical, 4,
            { label, unavail_list })
        unavail_container:set_css_class("group-box")
    end

    ---@param rescan? boolean
    local function on_refresh(rescan)
        refresh:set_sensitive(false)
        ctx:spawn_local(function()
            local aps = networkmanager_service:get_access_points(rescan)
            local is_known_lookup = {}
            local known_connections = networkmanager_service:get_known_wifi_connections() or {}
            for i = 1, #known_connections do
                local conn = known_connections[i]
                is_known_lookup[conn.ssid] = true
            end

            refresh:set_sensitive(true)

            if not aps then return end

            avail_list:remove_all()
            unavail_list:remove_all()

            local primary_conn = networkmanager_service.primary_connection
            local primary_conn_ssid = primary_conn and primary_conn.ssid
            local num_known_connections_found = 0
            for i = 1, #aps do
                local ap = aps[i]
                local ssid = ap.ssid
                if #ssid == 0 then goto continue end
                if ssid == primary_conn_ssid then goto continue end

                local ap_button = gtk.Button.new()
                ap_button:set_css_class("ap")

                local ap_container = gtk.Box.new(gtk.Orientation.Horizontal, 8)
                local icon = gtk.Label.new(get_wifi_icon(true, ap.signal))
                icon:set_css_class("icon")

                local ssid_label = gtk.Label.new(ssid)
                ssid_label:set_css_class("ssid")
                ssid_label:set_ellipsize(gtk.EllipsizeMode.End)

                ap_container:append(icon:upcast())
                ap_container:append(ssid_label:upcast())
                ap_button:set_child(ap_container:upcast())

                if is_known_lookup[ssid] then
                    num_known_connections_found = num_known_connections_found + 1
                    avail_list:append(ap_button:upcast())
                    ap_button:connect_clicked(function()
                        ctx:spawn_local(function()
                            local proc = gio.Subprocess.new({ "nmcli", "c", "up", ssid })
                            proc:wait()

                            on_refresh()
                        end)
                    end)
                else
                    unavail_list:append(ap_button:upcast())
                    ap_button:connect_clicked(function()
                        -- Connection to a unknown network is a privileged operation
                        ctx:spawn_local(function()
                            local pass_res = dialog.dialog_password("Enter the Wi-Fi password.")
                            if not pass_res or not pass_res.success then return end

                            local sudo_res = dialog.dialog_password("This operation requires authentication.")
                            if not sudo_res or not sudo_res.success then return end

                            ap_button:set_sensitive(false)

                            local proc = gio.Subprocess.new(
                                { "sudo", "-S", "nmcli", "d", "wifi", "connect", ssid, "password", sudo_res.data
                                    .password },
                                { stdin_pipe = true })
                            proc:communicate(sudo_res.data.password)

                            -- TODO: Show error
                            if proc:exit_status() == 0 then
                                on_refresh(false)
                            end

                            ap_button:set_sensitive(true)
                        end)
                    end)
                end

                ::continue::
            end

            avail_container:set_visible(num_known_connections_found > 0)
        end)
    end

    refresh:connect_clicked(function() on_refresh(true) end)

    buttons_container:append(refresh:upcast())
    buttons_container:append(close:upcast())

    container:append(buttons_container:upcast())
    container:append(active_ap_container:upcast())

    container:append(avail_container:upcast())
    container:append(unavail_container:upcast())

    return {
        widget = container,
        list = unavail_list,
        refresh = refresh,
        close = close,
        on_refresh = on_refresh
    }
end

---@param pulseaudio_service PulseaudioService
---@param networkmanager_service NetworkManagerService
local function build_main_content(pulseaudio_service, networkmanager_service)
    local container = gtk.Box.new(gtk.Orientation.Vertical, 4)
    container:set_css_class("content")

    local main_content = {
        quick_options = build_quick_options(networkmanager_service),
        battery_info = build_battery_info(),
        sliders = build_sliders(pulseaudio_service),

        add = function(self)
            container:append(self.quick_options.widget:upcast())
            container:append(self.battery_info:upcast())
            container:append(self.sliders:upcast())
        end
    }

    local wifi_list = {
        widget = build_wifi_list(networkmanager_service),

        add = function(self)
            container:append(self.widget.widget:upcast())
        end
    }

    main_content:add()
    main_content.quick_options.wifi.chevron:connect_clicked(function()
        container:remove_all()
        wifi_list:add()
        wifi_list.widget.on_refresh(false)
    end)

    wifi_list.widget.close:connect_clicked(function()
        container:remove_all()
        main_content:add()
    end)

    return container
end

---@class SidebarWidget
---@field close fun():nil

---@param app Application
---@param pulseaudio_mainloop Mainloop
---@return SidebarWidget
local function build_sidebar(app, pulseaudio_mainloop)
    local window = gtk.ApplicationWindow.new(app)
    window:set_css_class("sidebar")

    local revealer = gtk.Revealer.new()
    revealer:set_transition_type(gtk.RevealerTransitionType.SlideLeft)
    revealer:set_transition_duration(1000)

    -- Reveal on load
    local ctx = glib.MainContext.default()
    ctx:spawn_local_with_priority(glib.Priority.DEFAULT_IDLE, function()
        revealer:set_reveal_child(true)
    end)

    local pulseaudio_service = PulseaudioService.new(pulseaudio_mainloop)
    local networkmanager_service = NetworkManagerService.new()

    revealer:set_child(build_main_content(pulseaudio_service, networkmanager_service):upcast())
    window:set_child(revealer:upcast())

    gtk.layer_shell.init_for_window(window)
    gtk.layer_shell.set_layer(window, gtk.layer_shell.Layer.Top)
    gtk.layer_shell.set_anchor(window, gtk.layer_shell.Edge.Top, true)
    gtk.layer_shell.set_anchor(window, gtk.layer_shell.Edge.Bottom, true)
    gtk.layer_shell.set_anchor(window, gtk.layer_shell.Edge.Right, true)
    gtk.layer_shell.set_namespace(window, "sidebar")

    window:present()

    return {
        close = function()
            -- TODO: Revealer doesnt work
            window:close()
        end
    }
end

local function load_css()
    local css_data = utils.scss_from_path("./sidebar.scss")

    local provider = gtk.CssProvider.new()
    provider:load_from_data(css_data)

    gtk.style_context_add_provider(provider)
end

local mainloop = pulseaudio.Mainloop.new()
local app = gtk.Application.new("org.gtk_rs.RightSidebar")

---@type SidebarWidget?
local sidebar
app:connect_activate(function()
    if sidebar then
        sidebar.close()
        return
    end

    load_css()
    sidebar = build_sidebar(app, mainloop)
end)
app:run()
