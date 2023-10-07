local gtk = crabshell.gtk

local app = gtk.Application.new("org.gtk_rs.Test")
app:connect_activate(function()
    local win = gtk.ApplicationWindow.new(app)

    local huh = gtk.Box.new(gtk.Orientation.Horizontal)
    gtk.MainContext.default():spawn_local(function()
        local flip = false
        while true do
            utils.sleep(0.1)
            win:set_visible(flip)
            flip = not flip
        end
    end)

    local btn = gtk.Button.with_label("Test")
    local controller = gtk.EventControllerScroll.new({ horizontal = true, kinetic = true })
    controller:connect_scroll_begin(function()
        print("Scroll begin")
    end)
    controller:connect_scroll(function(dx, dy)
        print("Scroll", dx, dy)
    end)
    controller:connect_decelerate(function(vel_x, vel_y)
        print("Decel", vel_x, vel_y)
    end)
    controller:connect_scroll_end(function()
        print("Scroll begin")
    end)
    btn:add_controller(controller:upcast())

    local controller = gtk.EventControllerMotion.new()
    print(controller)
    controller:connect_enter(function(x, y)
        print("Motion enter", x, y)
    end)
    controller:connect_motion(function(x, y)
        print("Motion", x, y)
    end)
    controller:connect_leave(function()
        print("Motion leave")
    end)
    btn:add_controller(controller:upcast())

    local controller = gtk.EventControllerFocus.new()
    controller:connect_enter(function()
        print("Focus enter")
    end)
    controller:connect_leave(function()
        print("Focus leave")
    end)
    btn:add_controller(controller:upcast())

    gtk.layer_shell.init_for_window(win)

    huh:append(btn:upcast())
    win:set_child(huh:upcast())
    win:present()
end)
app:run()
app:run()
