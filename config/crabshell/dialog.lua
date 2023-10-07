local params = { ... }

local gtk = crabshell.gtk
local utils = crabshell.utils

---@param success boolean
---@param data? DialogData
local function return_result(success, data)
    print(utils.json.to_string { success = success, data = data })
end

---@param window ApplicationWindow
---@param container Box
---@param title string
local function build_dialog_prompt(window, container, title)
    local title_label = gtk.Label.new(title)
    title_label:set_css_class("title")

    local actions_container = gtk.Box.new(gtk.Orientation.Horizontal, 4)
    local yes_button = gtk.Button.with_label("Yes")
    yes_button:set_hexpand(true)
    yes_button:set_vexpand(true)
    yes_button:set_css_class("yes")
    yes_button:connect_clicked(function()
        return_result(true)
        window:close()
    end)

    local no_button = gtk.Button.with_label("No")
    no_button:set_hexpand(true)
    no_button:set_vexpand(true)
    no_button:set_css_class("no")
    no_button:connect_clicked(function()
        return_result(false)
        window:close()
    end)

    actions_container:append(yes_button:upcast())
    actions_container:append(no_button:upcast())

    container:append(title_label:upcast())
    container:append(actions_container:upcast())
end



---@param window ApplicationWindow
---@param container Box
---@param title string
local function build_password_dialog(window, container, title)
    local title_label = gtk.Label.new(title)
    title_label:set_css_class("title")

    local entry = gtk.Entry.new()
    entry:set_visibility(false)
    entry:set_placeholder_text("Password")

    local function on_ok()
        return_result(true, { password = entry:buffer():text() })
        window:close()
    end

    entry:connect_activate(on_ok)

    local actions_container = gtk.Box.new(gtk.Orientation.Horizontal, 4)
    local ok_button = gtk.Button.with_label("Ok")
    ok_button:set_hexpand(true)
    ok_button:set_vexpand(true)
    ok_button:set_css_class("yes")
    ok_button:connect_clicked(function()
        on_ok()
    end)

    local cancel_button = gtk.Button.with_label("Cancel")
    cancel_button:set_hexpand(true)
    cancel_button:set_vexpand(true)
    cancel_button:set_css_class("no")
    cancel_button:connect_clicked(function()
        return_result(false)
        window:close()
    end)

    actions_container:append(ok_button:upcast())
    actions_container:append(cancel_button:upcast())

    container:append(title_label:upcast())
    container:append(entry:upcast())
    container:append(actions_container:upcast())
end

---@param app Application
---@param title string
---@param type DialogType
local function build_dialog(app, title, type)
    local window = gtk.ApplicationWindow.new(app)
    window:set_css_class("dialog")
    window:set_size_request(512, 220)

    local container = gtk.Box.new(gtk.Orientation.Vertical, 16)

    if type == "prompt" then
        build_dialog_prompt(window, container, title)
    elseif type == "password" then
        build_password_dialog(window, container, title)
    end

    local event_controller = gtk.EventControllerKey.new()
    event_controller:connect_key_pressed(function(key_name)
        if key_name == "Escape" then
            return_result(false)
            window:close()
        end
    end)
    window:add_controller(event_controller:upcast())

    gtk.layer_shell.init_for_window(window)
    gtk.layer_shell.set_keyboard_mode(window, gtk.layer_shell.KeyboardMode.Exclusive)
    gtk.layer_shell.set_namespace(window, "dialog")

    window:set_child(container:upcast())
    window:present()
end

local function load_css()
    local css_data = utils.scss_from_path("./dialog.scss")

    local provider = gtk.CssProvider.new()
    provider:load_from_data(css_data)

    gtk.style_context_add_provider(provider)
end

local title_param = params[1]
local type_param = params[2]
if not title_param then
    return_result(false, { reason = "No title param" })
    return
end

---@type table<DialogType, boolean>
local VALID_DIALOG_TYPES = { prompt = true, password = true }
if not type_param or not VALID_DIALOG_TYPES[type_param] then
    return_result(false, { reason = "No type param" })
    return
elseif not VALID_DIALOG_TYPES[type_param] then
    return_result(false, { reason = "Invalid type param" })
    return
end

local app = gtk.Application.new("org.gtk_rs.Dialog")
app:connect_activate(function()
    load_css()
    build_dialog(app, title_param, params[2])
end)

app:run()
