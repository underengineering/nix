local app = gtk.Application.new("org.gtk_rs.SidebarTest")
app:connect_activate(function()
    local css_provider = gtk.CssProvider.new()
    css_provider:load_from_data([[
        .window { background-color: transparent; }
        .revealer { background-color: transparent; }
        .container { background-color: red; }
    ]])
    gtk.style_context_add_provider(css_provider)

    local window = gtk.ApplicationWindow.new(app)
    window:set_css_class("window")

    local revealer = gtk.Revealer.new()
    revealer:set_css_class("revealer")
    revealer:set_reveal_child(false)
    revealer:set_transition_duration(1000)
    revealer:set_transition_type(gtk.RevealerTransitionType.SlideLeft)

    local container = gtk.Box.new(gtk.Orientation.Vertical, 4)
    container:set_css_class("container")
    local label = gtk.Label.new("Label AAAAAAAAAAAAAAA")
    container:append(label:upcast())

    revealer:set_child(container:upcast())

    gtk.MainContext.default():spawn_local_with_priority(gtk.Priority.DEFAULT_IDLE, function()
        revealer:set_reveal_child(true)
    end)

    gtk.layer_shell.init_for_window(window)
    gtk.layer_shell.set_layer(window, gtk.layer_shell.Layer.Top)
    gtk.layer_shell.set_anchor(window, gtk.layer_shell.Edge.Top, true)
    gtk.layer_shell.set_anchor(window, gtk.layer_shell.Edge.Bottom, true)
    gtk.layer_shell.set_anchor(window, gtk.layer_shell.Edge.Right, true)
    gtk.layer_shell.set_namespace(window, "sidebar")

    window:set_child(revealer:upcast())
    window:present()
end)
app:run()
