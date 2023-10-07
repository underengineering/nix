local gio = crabshell.gio
local glib = crabshell.glib
local gtk = crabshell.gtk
local utils = crabshell.utils

---@class AppWidget
---@field button Button
---@field container Box
---@field icon Image
---@field name Label
local AppWidget = {
    ---@param self AppWidget
    ---@param app_info AppInfo
    ---@param on_clicked fun(self: AppWidget, app_info: AppInfo):nil
    bind = function(self, app_info, on_clicked)
        self.button:connect_clicked(function()
            on_clicked(self, app_info)
        end)

        local gicon = app_info:icon()
        if gicon then
            -- Do not apply delay if the icon is already loaded
            self.icon:set_from_gicon(gicon)
        end

        self.name:set_label(app_info:display_name())
    end,
    ---@param _ AppWidget
    unbind = function(_)
    end
}

---@return AppWidget
function AppWidget.new()
    local button = gtk.Button.new()
    button:add_css_class("app")
    button:set_hexpand(true)

    local container = gtk.Box.new(gtk.Orientation.Horizontal, 4)
    local icon = gtk.Image.new()
    icon:set_css_class("icon")
    icon:set_pixel_size(40)
    icon:set_size_request(40, 40)

    local name = gtk.Label.new()
    name:set_css_class("name")
    name:set_ellipsize(gtk.EllipsizeMode.End)

    button:set_child(container:upcast())

    container:append(icon:upcast())
    container:append(name:upcast())

    return setmetatable({
        button = button,
        container = container,
        icon = icon,
        name = name
    }, AppWidget)
end

AppWidget.__index = AppWidget

---@class AppWidgetPool
---@field unused_pool AppWidget[]
local AppWidgetPool = {
    ---@param self AppWidgetPool
    ---@param app_info AppInfo
    ---@param on_clicked fun(app: AppWidget, app_info: AppInfo):nil
    ---@return AppWidget
    alloc = function(self, app_info, on_clicked)
        -- Try to reuse existing widget
        if #self.unused_pool > 0 then
            ---@type AppWidget
            local widget = table.remove(self.unused_pool)
            widget:bind(app_info, on_clicked)

            return widget
        end

        -- Allocate new
        local widget = AppWidget.new()
        widget:bind(app_info, on_clicked)

        return widget
    end,
    ---@param self AppWidgetPool
    ---@param widget AppWidget
    free = function(self, widget)
        widget:unbind()
        self.unused_pool[#self.unused_pool + 1] = widget
    end
}

AppWidgetPool.__index = AppWidgetPool

---@return AppWidgetPool
function AppWidgetPool.new()
    return setmetatable({
        unused_pool = {}
    }, AppWidgetPool)
end

---@param on_changed fun(query: string):nil
---@param on_enter fun():nil
local function build_search_bar(on_changed, on_enter)
    local container = gtk.Box.new(gtk.Orientation.Horizontal, 4)
    container:set_css_class("prompt")

    local label = gtk.Label.new("Search:")
    label:set_css_class("label")
    container:append(label:upcast())

    local text_entry = gtk.Entry.new()
    text_entry:set_css_class("entry")
    text_entry:set_hexpand(true)
    text_entry:set_placeholder_text("Type to filter")
    text_entry:connect_activate(on_enter)

    local text_buffer = text_entry:buffer()
    text_buffer:connect_inserted_text(function()
        on_changed(text_buffer:text())
    end)

    text_buffer:connect_deleted_text(function()
        on_changed(text_buffer:text())
    end)

    container:append(text_entry:upcast())

    return { widget = container, label = label, text_entry = text_entry }
end

---@class AppGrid
---@field widget Grid
---@field add_app fun(app_info: AppInfo):nil
---@field clear fun():nil

---@param on_clicked fun(app: AppWidget, app_info: AppInfo):nil
---@return AppGrid
local function build_app_grid(on_clicked)
    local COLUMNS = 3
    local MAX = 18

    local container = gtk.Grid.new()
    local pool = AppWidgetPool.new()

    ---@type AppWidget[]
    local children = {}
    local idx = 0

    return {
        widget = container,
        ---@param app_info AppInfo
        add_app = function(app_info)
            if idx > MAX then
                return
            end

            local col = idx % COLUMNS
            local row = math.floor(idx / COLUMNS)

            local widget = pool:alloc(app_info, on_clicked)
            container:attach(widget.button:upcast(), col, row, 1, 1)

            children[idx + 1] = widget
            idx = idx + 1
        end,
        clear = function()
            container:remove_all()

            for i = 1, #children do
                local widget = children[i]

                pool:free(widget)
                children[i] = nil
            end

            idx = 0
        end
    }
end

---@param app_info AppInfo
---@param container Box
---@param app_grid AppGrid
local function try_launch(app_info, container, app_grid)
    local success, result = pcall(app_info.launch, app_info, {})
    if not success then
        -- Show the error
        local error_label = gtk.Label.new(("Error: %s"):format(result))
        container:remove(app_grid.widget:upcast())
        container:append(error_label:upcast())
        return false
    end

    return true
end

local function get_apps()
    local apps = gio.AppInfo.all()

    -- Filter from hidden
    for i = #apps, 1, -1 do
        local app = apps[i]
        if not app:should_show() then
            table.remove(apps, i)
        end
    end

    -- Sort by name
    table.sort(apps, function(a, b)
        return a:display_name() < b:display_name()
    end)

    return apps
end


---@param app Application
local function build_runner(app)
    local window = gtk.ApplicationWindow.new(app)
    window:set_css_class("runner")
    window:set_size_request(700, 380)

    local container = gtk.Box.new(gtk.Orientation.Vertical, 2)

    local app_grid
    app_grid = build_app_grid(function(_, app_info)
        if try_launch(app_info, container, app_grid) then
            -- Close on success
            window:close()
        end
    end)

    ---@type AppInfo?
    local first_app
    local apps = get_apps()

    ---@param query string?
    local function on_search(query)
        app_grid.clear()

        first_app = nil
        if query then query = query:lower() end
        for _, app_info in ipairs(apps) do
            if not query or app_info:display_name():lower():find(query, 1, true) then
                first_app = first_app or app_info
                app_grid.add_app(app_info)
            end
        end
    end

    local search_bar = build_search_bar(on_search, function()
        if not first_app then
            return
        end

        -- Run first app in the grid
        if try_launch(first_app, container, app_grid) then
            -- Close on success
            window:close()
        end
    end)

    local ignore_lookup = {
        Up = true,
        Right = true,
        Down = true,
        Left = true,

        Tab = true,
        ISO_Left_Tab = true
    }

    local event_controller = gtk.EventControllerKey.new()
    event_controller:connect_key_pressed(function(key_name)
        if key_name == "Escape" then
            window:close()
        elseif not ignore_lookup[key_name] then
            search_bar.text_entry:grab_focus_without_selecting()
        end
    end)
    window:add_controller(event_controller:upcast())

    -- Load all apps
    on_search()

    container:append(search_bar.widget:upcast())
    container:append(app_grid.widget:upcast())

    gtk.layer_shell.init_for_window(window)
    gtk.layer_shell.set_layer(window, gtk.layer_shell.Layer.Top)
    gtk.layer_shell.set_keyboard_mode(window, gtk.layer_shell.KeyboardMode.Exclusive)
    gtk.layer_shell.set_namespace(window, "runner")

    window:set_child(container:upcast())
    window:present()
end

local function load_css()
    local css_data = utils.scss_from_path("./runner.scss")

    local provider = gtk.CssProvider.new()
    provider:load_from_data(css_data)

    gtk.style_context_add_provider(provider)
end


local app = gtk.Application.new("org.gtk_rs.AppRunner")
app:connect_activate(function()
    load_css()
    build_runner(app)
end)

app:run()
