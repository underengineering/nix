local app = gtk.Application.new("org.gtk_rs.Test")
app:connect_activate(function()
    local win = gtk.ApplicationWindow.new(app)

    local ctx = gtk.MainContext.default()
    ctx:spawn_local(function()
        print(1)
    end)

    win:present()
end)
app:run()
