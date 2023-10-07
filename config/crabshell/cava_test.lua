local app = gtk.Application.new("org.gtk_rs.CavaTest")
app:connect_activate(function()
    local win = gtk.ApplicationWindow.new(app)

    local provider = gtk.CssProvider.new()
    provider:load_from_data([[
        .bar {
            background-color: red;
        }
    ]])
    gtk.style_context_add_provider(provider)

    local mainbox = gtk.Box.new(gtk.Orientation.Vertical)
    local overlay = gtk.Overlay.new()
    mainbox:append(overlay:upcast())

    local text = gtk.Label.new("hello world")

    local container = gtk.Box.new(gtk.Orientation.Horizontal)
    container:set_size_request(16, 16)
    container:set_halign(gtk.Align.Center)

    overlay:set_child(container:upcast())
    overlay:add_overlay(text:upcast())

    ---@type Box[]
    local bars = {}
    for i = 1, 16 do
        local zoz = gtk.Box.new(gtk.Orientation.Horizontal)
        local box = gtk.Label.new("a")
        box:add_css_class("bar")
        box:set_size_request(0, 0)
        -- container:append(box:upcast())
        zoz:append(box:upcast())
        container:append(zoz:upcast())
        bars[i] = zoz
    end

    local ctx = gtk.MainContext.default()
    ctx:spawn_local(function()
        local proc = gio.Subprocess.new({ "cava", "-p", "/tmp/Downloads/cava.conf" },
            { stdout_pipe = true, stderr_silence = true })
        local stdout = proc:stdout()
        assert(stdout)

        while true do
            local chunk = stdout:read(16)
            if #chunk > 0 then
                for i = 1, #chunk do
                    local bytes = chunk:byte(i)
                    bars[i]:set_size_request(4, math.random() * 64) --bytes / 255 * 64)
                end
            end
        end
        print("ded...")
    end)

    win:set_child(mainbox:upcast())
    win:present()
end)
app:run()
