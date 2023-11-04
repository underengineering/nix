local gtk = crabshell.gtk
local gio = crabshell.gio
local glib = crabshell.glib
local utils = crabshell.utils
local worker = crabshell.worker.Worker.start([[
-- glib.MainContext.thread_default():spawn_local(function()
while true do
    print("[thread] Receiving")

    local path = crabshell.worker.receiver:recv_blocking()
    print("[thread] path:", path)

    local tex = crabshell.gdk.Texture.from_filename(path)
    print("[thread] tex:", tex)

    crabshell.worker.sender:send_blocking(tex)
end
-- end)
]], "worker", 1)

local sender = worker:sender()
local receiver = worker:receiver()

local app = gtk.Application.new("org.gtk_rs.TextureTest")
app:connect_activate(function()
    local win = gtk.ApplicationWindow.new(app)

    local image = gtk.Image.new()
    win:set_child(image:upcast())

    local ctx = glib.MainContext.default()
    ctx:spawn_local(function()
        while true do
            print("[master] Sleep")
            utils.sleep(1)

            print("[master] Sending")
            sender:send("/home/mika/.config/nix/wallpapers/wallpaper.png")

            local tex = receiver:recv()
            print("[master] Tex:", tex)

            image:set_from_paintable(tex)
        end
    end)

    win:present()
end)
app:run()
