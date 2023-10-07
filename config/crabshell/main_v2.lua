---@module 'defs/defs.lua'

local function build_distro_icon()
    local container = gtk.Box.new(gtk.Orientation.Horizontal, 0)
    container:set_css_classes { "widget", "distro-icon" }

    local image = gtk.Image.from_file("./assets/nix-snowflake.svg")
    container:append(image:upcast())

    return container
end

---@param receiver Receiver
local function build_workspaces(receiver)
    local MAIN_MONITOR = "eDP-2"

    local ctx = gtk.MainContext.default()

    local container = gtk.Box.new(gtk.Orientation.Horizontal, 0)
    container:set_css_classes { "widget", "workspaces" }

    ---@type table<string, Button>
    local workspace_widgets = {}

    -- Always sorted
    ---@type string[]
    local workspace_names = {}

    ---@type string?
    local active_workspace = nil
    local function set_active_workspace(name)
        -- Remove `active` from old active workspace btn
        if active_workspace then
            local btn = workspace_widgets[active_workspace]
            btn:remove_css_class("active")
        end

        -- Mark passed workspace as active
        local btn = workspace_widgets[name]
        btn:add_css_class("active")
        active_workspace = name
    end

    ---@param name string
    ---@param sort boolean?
    local function add_workspace(name, sort)
        local btn = gtk.Button.new()
        btn:set_size_request(30, btn:allocated_height())
        btn:set_css_classes { "widget", "workspace" }
        btn:set_label(name)
        btn:connect_clicked(function()
            io.popen(("hyprctl dispatch workspace '%s'"):format(name)):close()
        end)

        container:append(btn:upcast())
        workspace_widgets[name] = btn
        workspace_names[#workspace_names + 1] = name

        if sort then
            -- Sort workspace names
            table.sort(workspace_names)

            -- Remove all widgets
            for _, widget in pairs(workspace_widgets) do
                container:remove(widget:upcast())
            end

            -- Add widgets back sorted
            for _, workspace_name in ipairs(workspace_names) do
                local widget = workspace_widgets[workspace_name]
                container:append(widget:upcast())
            end
        end
    end

    ---@param name string
    local function remove_workspace(name)
        local widget = workspace_widgets[name]
        if not widget then
            return
        end

        container:remove(widget:upcast())
        workspace_widgets[name] = nil
        for idx = 1, #workspace_names do
            if name == workspace_names[idx] then
                table.remove(workspace_names, idx)
                break
            end
        end
    end

    ctx:spawn_local(function()
        local workspaces = hyprland.ipc.get_workspaces()
        table.sort(workspaces, function(a, b) return a.id < b.id end)
        for i = 1, #workspaces do
            local workspace = workspaces[i]
            add_workspace(workspace.name, false)
        end

        local monitors = hyprland.ipc.get_monitors()
        for _, monitor in ipairs(monitors) do
            if monitor.name == MAIN_MONITOR then
                set_active_workspace(monitor.activeWorkspace.name)
                break
            end
        end

        while true do
            local event = receiver:recv()
            if not event then
            elseif event.CreateWorkspace then
                local workspace = event.CreateWorkspace
                add_workspace(workspace.name, true)
            elseif event.DestroyWorkspace then
                local workspace = event.DestroyWorkspace
                remove_workspace(workspace.name)
            elseif event.Workspace then
                local workspace = event.Workspace
                set_active_workspace(workspace.name)
            end
        end
    end)

    return container
end

---@param receiver Receiver
local function build_active_window(receiver)
    local ctx = gtk.MainContext.default()
    local container = gtk.Box.new(gtk.Orientation.Horizontal, 4)
    container:set_css_classes { "widget", "active-window" }

    local image = gtk.Image.new()
    local label = gtk.Label.new()

    container:append(image:upcast())
    container:append(label:upcast())

    ---@param text string
    local function wrap_text(text)
        if utf8.len(text) > 70 then
            return utf8.sub(text, 1, 70) .. "..."
        end

        return text
    end

    ---@type table<string, string|boolean>
    local icon_cache = {}

    local icon_theme = image:settings():gtk_icon_theme_name()

    ---@return string?
    local function lookup_icon(name)
        local entry = icon_cache[name]
        if entry ~= nil then
            if entry == false then return nil end

            ---@diagnostic disable-next-line: return-type-mismatch
            return entry
        end

        local icon = utils.lookup_icon(name, { theme = icon_theme, size = 24, cache = false })
        icon_cache[name] = icon

        return icon
    end

    local is_visible = true

    ---@param new_value boolean
    local function set_visible(new_value)
        if new_value == is_visible then
            return
        end

        is_visible = new_value
        container:set_visible(new_value)
    end

    ctx:spawn_local(function()
        set_visible(false)

        while true do
            local event = receiver:recv()
            if not event then
            elseif event.ActiveWindow then
                local active_window = event.ActiveWindow
                if active_window.title then
                    local icon = lookup_icon(active_window.class)
                    if icon then
                        image:set_from_file(icon)
                    else
                        image:clear()
                    end

                    local title = wrap_text(active_window.title)
                    label:set_label(title)
                end

                set_visible(#active_window.title > 0)
            end
        end
    end)

    return container
end

---@param system System
local function build_network(system)
    -- ip route show match 1.1.1.1
    local MAIN_INTERFACE = "wlp4s0"

    local ctx = gtk.MainContext.default()
    local container = gtk.Box.new(gtk.Orientation.Horizontal, 0)
    container:set_css_classes { "widget", "network" }

    local label = gtk.Label.new()
    container:append(label:upcast())

    ---@param value integer
    local function format_traffic(value)
        if value < 1024 then
            return ("%uB"):format(value)
        end

        if value < 1048576 then
            return ("%.1fKB"):format(value / 1024)
        end

        return ("%.1fMB"):format(value / 1048576)
    end

    ctx:spawn_local(function()
        while true do
            local networks = system:networks()
            local main_network = networks[MAIN_INTERFACE]
            if main_network then
                local up = format_traffic(main_network.transmitted)
                local down = format_traffic(main_network.received)
                label:set_label(("󰕒 %s󰇚 %s"):format(up, down))
            end

            utils.sleep(2)
        end
    end)

    return container
end

local function build_battery()
    local MAIN_BATTERY = "BAT0"

    local ctx = gtk.MainContext.default()
    local container = gtk.Box.new(gtk.Orientation.Horizontal, 0)
    container:set_css_classes { "widget", "battery" }

    local label = gtk.Label.new("0%")
    container:append(label:upcast())

    local ICONS_CHARGING = { "󰢟 ", "󰢜 ", "󰂆 ", "󰂇 ", "󰂈 ", "󰢝 ", "󰂉 ", "󰢞 ", "󰂊 ", "󰂋 ",
        "󰂅 " }
    local ICONS = { "󰂎 ", "󰁺 ", "󰁻 ", "󰁼 ", "󰁽 ", "󰁾 ", "󰁿 ", "󰂀 ", "󰂁 ", "󰂂 ", "󰁹 " }

    ---@param capacity integer
    ---@param status string
    local function get_battery_icon(capacity, status)
        if status == "Charging" then
            local idx = math.floor(capacity / 100 * #ICONS_CHARGING + 1.5)
            return ICONS_CHARGING[idx]
        end

        local idx = math.floor(capacity / 100 * #ICONS + 1.5)
        return ICONS[idx]
    end

    ctx:spawn_local(function()
        while true do
            local batteries = sysinfo.battery.get_batteries()
            local main_battery = batteries.info[MAIN_BATTERY]
            if main_battery then
                local icon = get_battery_icon(batteries.total_capacity, main_battery.status)
                label:set_label(("%s%u%%"):format(icon, batteries.total_capacity))
            end

            utils.sleep(5)
        end
    end)

    return container
end

---@param system System
local function build_cpu(system)
    local ctx = gtk.MainContext.default()
    local container = gtk.Box.new(gtk.Orientation.Horizontal, 0)
    container:set_css_classes { "widget", "cpu" }

    local label = gtk.Label.new(" 0%")
    container:append(label:upcast())

    ctx:spawn_local(function()
        while true do
            local cpu = system:global_cpu_info()

            label:set_label((" %u%%"):format(cpu.cpu_usage))
            utils.sleep(2)
        end
    end)

    return container
end

---@param system System
local function build_memory(system)
    local ctx = gtk.MainContext.default()
    local container = gtk.Box.new(gtk.Orientation.Horizontal, 0)
    container:set_css_classes { "widget", "memory" }

    local label = gtk.Label.new("󰍛 0%")
    container:append(label:upcast())

    ctx:spawn_local(function()
        while true do
            local total = system:total_memory()
            local used = system:used_memory()

            label:set_label(("󰍛 %u%%"):format(used / total * 100))
            utils.sleep(2)
        end
    end)

    return container
end


---@param mainloop Mainloop
local function build_volume(mainloop)
    local container = gtk.Box.new(gtk.Orientation.Horizontal, 0)
    container:set_css_classes { "widget", "volume" }

    local label = gtk.Label.new("sex")
    container:append(label:upcast())

    local context = pulseaudio.Context.new(mainloop, "cbar")

    local is_bluetooth = false

    ---@type integer
    local current_sink_index

    local VOLUME_ICONS = { "󰕿", "󰖀", "󰕾" }
    local VOLUME_MUTED_ICON = "󰖁"
    local BLUETOOTH_ICON = "󰂰"
    local BLUETOOTH_MUTED_ICON = "󰂲"

    ---@param volume integer
    ---@param muted boolean
    local function get_volume_icon(volume, muted)
        if muted then
            return VOLUME_MUTED_ICON
        end

        local idx = math.floor(volume / 100 * #VOLUME_ICONS + 1.5)
        return VOLUME_ICONS[idx]
    end

    ---@param new_value boolean
    local function update_bluetooth(new_value)
        if is_bluetooth == new_value then
            return
        end

        if new_value then
            container:add_css_class("bluetooth")
        else
            container:remove_css_class("bluetooth")
        end

        is_bluetooth = new_value
    end

    ---@param sink SinkInfo
    local function is_bluetooth_sink(sink)
        local name = sink.name
        if name:find("bluez", 1, true) then
            return true
        end

        return false
    end

    ---@param sink SinkInfo
    local function on_sink_updated(sink)
        local volume_abs = sink.volume[1]
        local volume_norm = volume_abs / pulseaudio.Volume.NORMAL
        local volume = volume_norm * 100

        local icon
        if is_bluetooth then
            if sink.mute then
                icon = BLUETOOTH_MUTED_ICON
            else
                icon = BLUETOOTH_ICON
            end
        else
            icon = get_volume_icon(volume, sink.mute)
        end

        label:set_label(("%s %u%%"):format(icon, volume + 0.5))
    end

    ---@param op Operation
    ---@param index integer
    local function on_event(_, op, index)
        if op == pulseaudio.Operation.Removed then
            -- If the removed sink id is the current sink id
            if index == current_sink_index then
                -- Get info about new sink
                context:get_server_info(function(info)
                    context:get_sink_info_by_name(info.default_sink_name, function(sink)
                        current_sink_index = sink.index
                        update_bluetooth(is_bluetooth_sink(sink))
                        on_sink_updated(sink)
                    end)
                end)
            end

            -- Cannot get sink info after it's removal
            return
        end

        -- TODO: test switching main sink
        context:get_sink_info_by_index(index, function(sink)
            if op == pulseaudio.Operation.New then
                current_sink_index = index
                update_bluetooth(is_bluetooth_sink(sink))
            end

            if sink.index == current_sink_index then
                on_sink_updated(sink)
            end
        end)
    end

    local function on_context_ready()
        context:get_server_info(function(info)
            local default_sink = info.default_sink_name
            context:get_sink_info_by_name(default_sink, function(sink)
                current_sink_index = sink.index
                update_bluetooth(is_bluetooth_sink(sink))
                on_sink_updated(sink)
            end)
        end)

        context:subscribe({ sink = true }, function()
            context:set_subscribe_callback(on_event)
        end)
    end

    context:connect()
    context:set_state_callback(function()
        local state = context:get_state()
        if state == pulseaudio.State.Ready then
            on_context_ready()
        end
    end)

    return container
end

---@param receiver Receiver
local function build_layout(receiver)
    local ctx = gtk.MainContext.default()
    local container = gtk.Box.new(gtk.Orientation.Horizontal, 0)
    container:set_css_classes { "widget", "layout" }

    local label = gtk.Label.new("EN")
    container:append(label:upcast())

    local mapping = {
        ["English (US)"] = "EN",
        ["Russian"] = "RU"
    }

    ctx:spawn_local(function()
        local devices = hyprland.ipc.get_devices()
        for _, keyboard in ipairs(devices.keyboards) do
            if keyboard.main then
                label:set_label(mapping[keyboard.active_keymap])
                break
            end
        end

        while true do
            local event = receiver:recv()
            if not event then
            elseif event.ActiveLayout then
                local layout = event.ActiveLayout
                label:set_label(mapping[layout.layout_name])
            end
        end
    end)

    return container
end

local function build_clock()
    local ctx = gtk.MainContext.default()
    local container = gtk.Box.new(gtk.Orientation.Horizontal, 0)
    container:set_css_classes { "widget", "clock" }

    local label = gtk.Label.new()
    container:append(label:upcast())

    ctx:spawn_local(function()
        while true do
            local time = os.date("󰅐 %H:%M")

            ---@cast time string
            label:set_label(time)
            utils.sleep(15)
        end
    end)

    return container
end

---@param app Application
---@param title string
---@param callback fun():nil
local function build_dialog(app, title, callback)
    local window = gtk.ApplicationWindow.new(app)
    window:set_css_class("dialog")
    window:set_size_request(512, 220)

    local container = gtk.Box.new(gtk.Orientation.Vertical, 16)

    local title_label = gtk.Label.new(title)
    title_label:set_css_class("title")

    local actions_container = gtk.Box.new(gtk.Orientation.Horizontal, 4)
    local yes_button = gtk.Button.with_label("Yes")
    yes_button:set_hexpand(true)
    yes_button:set_vexpand(true)
    yes_button:set_css_class("yes")
    yes_button:connect_clicked(function()
        callback()
        window:close()
    end)

    local no_button = gtk.Button.with_label("No")
    no_button:set_hexpand(true)
    no_button:set_vexpand(true)
    no_button:set_css_class("no")
    no_button:connect_clicked(function()
        window:close()
    end)

    actions_container:append(yes_button:upcast())
    actions_container:append(no_button:upcast())

    container:append(title_label:upcast())
    container:append(actions_container:upcast())

    gtk.layer_shell.init_for_window(window)
    gtk.layer_shell.set_namespace(window, "dialog")

    window:set_child(container:upcast())
    window:present()
end

---@param app Application
local function build_power_menu(app)
    local container = gtk.Box.new(gtk.Orientation.Horizontal, 0)
    container:set_css_classes { "widget", "powermenu-btn" }

    local btn = gtk.Button.with_label("")
    container:append(btn:upcast())

    ---@type ApplicationWindow?
    local window = nil
    local function close()
        if not window then return end

        window:close()
        window = nil
    end

    btn:connect_clicked(function()
        if window then
            window:close()
            window = nil
            return
        end

        window = gtk.ApplicationWindow.new(app)
        window:set_css_class("powermenu")
        window:set_size_request(512, 320)

        local buttons = gtk.Grid.new()

        local poweroff_btn = gtk.Button.with_label("")
        poweroff_btn:set_css_class("poweroff")
        poweroff_btn:set_hexpand(true)
        poweroff_btn:set_vexpand(true)
        poweroff_btn:connect_clicked(function()
            close()

            build_dialog(app, "Do you really want to power off?", function()
                io.popen("systemctl poweroff -i"):close()
            end)
        end)

        local restart_btn = gtk.Button.with_label("󰜉")
        restart_btn:set_css_class("restart")
        restart_btn:set_hexpand(true)
        restart_btn:set_vexpand(true)
        restart_btn:connect_clicked(function()
            close()

            build_dialog(app, "Do you really want to restart?", function()
                io.popen("systemctl reboot -i"):close()
            end)
        end)

        local suspend_btn = gtk.Button.with_label("󰒲")
        suspend_btn:set_css_class("suspend")
        suspend_btn:set_hexpand(true)
        suspend_btn:set_vexpand(true)
        suspend_btn:connect_clicked(function()
            close()

            build_dialog(app, "Do you really want to suspend?", function()
                io.popen("systemctl suspend"):close()
            end)
        end)

        local logout_btn = gtk.Button.with_label("󰍃")
        logout_btn:set_css_class("logout")
        logout_btn:set_hexpand(true)
        logout_btn:set_vexpand(true)
        logout_btn:connect_clicked(function()
            close()

            build_dialog(app, "Do you really want to logout?", function()
                io.popen("hyprctl dispatch exit"):close()
            end)
        end)

        buttons:attach(poweroff_btn:upcast(), 0, 0, 1, 1)
        buttons:attach(restart_btn:upcast(), 0, 1, 1, 1)
        buttons:attach(suspend_btn:upcast(), 1, 0, 1, 1)
        buttons:attach(logout_btn:upcast(), 1, 1, 1, 1)

        gtk.layer_shell.init_for_window(window)
        gtk.layer_shell.set_layer(window, gtk.layer_shell.Layer.Overlay)
        gtk.layer_shell.set_namespace(window, "powermenu")

        window:set_child(buttons:upcast())
        window:present()
    end)

    return container
end

---@param app Application
---@param system System
---@param event_loop EventLoop
---@param mainloop Mainloop
local function build_bar(app, system, event_loop, mainloop)
    local window = gtk.ApplicationWindow.new(app)
    window:set_css_class("bar")
    window:set_size_request(window:allocated_width(), 30)

    local widgets_box = gtk.CenterBox.new()

    local left = gtk.Box.new(gtk.Orientation.Horizontal, 4)
    local center = gtk.Box.new(gtk.Orientation.Horizontal, 4)
    local right = gtk.Box.new(gtk.Orientation.Horizontal, 4)

    widgets_box:set_start_widget(left:upcast())
    widgets_box:set_center_widget(center:upcast())
    widgets_box:set_end_widget(right:upcast())

    left:append(build_distro_icon():upcast())
    left:append(build_workspaces(event_loop:subscribe()):upcast())
    center:append(build_active_window(event_loop:subscribe()):upcast())
    right:append(build_network(system):upcast())
    right:append(build_battery():upcast())
    right:append(build_cpu(system):upcast())
    right:append(build_memory(system):upcast())
    right:append(build_volume(mainloop):upcast())
    right:append(build_layout(event_loop:subscribe()):upcast())
    right:append(build_clock():upcast())
    right:append(build_power_menu(app):upcast())

    gtk.layer_shell.init_for_window(window)
    gtk.layer_shell.auto_exclusive_zone_enable(window)
    gtk.layer_shell.set_anchor(window, gtk.layer_shell.Edge.Top, true)
    gtk.layer_shell.set_anchor(window, gtk.layer_shell.Edge.Left, true)
    gtk.layer_shell.set_anchor(window, gtk.layer_shell.Edge.Right, true)
    gtk.layer_shell.set_margin(window, gtk.layer_shell.Edge.Top, 2)
    gtk.layer_shell.set_margin(window, gtk.layer_shell.Edge.Left, 10)
    gtk.layer_shell.set_margin(window, gtk.layer_shell.Edge.Right, 10)
    gtk.layer_shell.set_layer(window, gtk.layer_shell.Layer.Top)
    if false then gtk.layer_shell.set_namespace(window, "bar") end

    window:set_child(widgets_box:upcast())
    window:present()
end

local function load_css()
    local css_data = utils.scss_from_path("./main.scss")

    local provider = gtk.CssProvider.new()
    provider:load_from_data(css_data)

    gtk.style_context_add_provider(provider)
end

-- Needs to be created before gtk.app:run for some reason
local mainloop = pulseaudio.Mainloop.new()
local app = gtk.Application.new("org.gtk_rs.Bar", { non_unique = true })
app:connect_activate(function()
    load_css()

    local system = sysinfo.System.new_with_specifics { memory = true, networks = true, networks_list = true }
    local event_loop = hyprland.EventLoop.new()
    build_bar(app, system, event_loop, mainloop)

    local ctx = gtk.MainContext.default()

    -- Connect the hyprland event loop
    ctx:spawn_local(function()
        event_loop:connect()
        event_loop:run()
    end)

    -- Refresh system stats
    ctx:spawn_local(function()
        while true do
            system:refresh_cpu()
            system:refresh_system()
            system:refresh_networks()
            utils.sleep(1)
            system:refresh_networks()
            utils.sleep(1)
        end
    end)
end)

app:run()
