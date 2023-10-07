local app = gtk.Application.new("org.gtk_rs.Cairo")
app:connect_activate(function()
    local win = gtk.ApplicationWindow.new(app)

    local cava_data = {}
    for i = 0, 15 do cava_data[i] = 0 end

    local area = gtk.DrawingArea.new()
    area:set_content_width(128)
    area:set_content_height(128)
    area:set_draw_func(function(ctx, width, height)
        for i = 0, 15 do
            local y = cava_data[i]
            ctx:rectangle(i / 16 * width, 0, width / 16, y / 255 * height)
        end
        ctx:fill()
    end)

    local ctx = gtk.MainContext.default()
    ctx:spawn_local(function()
        local proc = gio.Subprocess.new({ "cava", "-p", "/tmp/Downloads/cava.conf" },
            { stdout_pipe = true, stderr_silence = true })
        local stdout = proc:stdout()
        assert(stdout)

        local reader = stdout:into_async_buf_read(256)
        while true do
            local chunk = reader:read(16)
            if #chunk > 0 then
                for i = 1, #chunk do
                    cava_data[i - 1] = chunk:byte(i)
                    area:queue_draw()
                end
            end
        end

        print("ded...")
    end)

    win:set_child(area:upcast())
    win:present()
end)
app:run()
