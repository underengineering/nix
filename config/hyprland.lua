------------------
---- MONITORS ----
------------------

local scaledMonitor = { output = "", mode = "2560x1600@165", position = "auto", scale = 1.333333 }
local nativeMonitor = { output = "", mode = "2560x1600@165", position = "auto", scale = 1 }

hl.monitor(scaledMonitor)

-- TODO: god help
hl.env("AQ_DRM_DEVICES", "/dev/dri/card2")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("eval $(ssh-agent)")

    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("crabbar")
    hl.exec_cmd("swayidle -w before-sleep lock")

    -- https://github.com/NixOS/nixpkgs/issues/189851
    hl.exec_cmd(
    "sleep 1 && systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
-- TODO: breaks flatpak, see https://github.com/flathub/com.valvesoftware.Steam/issues/1552
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11")

hl.env("XCURSOR_SIZE", "32")
hl.env("HYPRCURSOR_SIZE", "32")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 1,

        col         = {
            active_border   = "rgb(b8bb26)",
            inactive_border = "rgb(3c3836)",
        },

        layout      = "dwindle",
    },

    decoration = {
        rounding = 0,

        blur = {
            enabled           = true,
            new_optimizations = true,
            size              = 5,
            passes            = 2,
        },

        shadow = {
            enabled      = true,
            range        = 10,
            render_power = 3,
            color        = "rgba(1d202175)",
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "overshot" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "default" })

hl.config({
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        disable_hyprland_logo  = true,
        vrr                    = 2,
        key_press_enables_dpms = true,
        disable_autoreload     = true,
        enable_anr_dialog      = false,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout     = "us, ru",
        kb_variant    = "",
        kb_model      = "",
        kb_options    = "grp:alt_shift_toggle",
        kb_rules      = "",

        follow_mouse  = 2,

        accel_profile = "flat",
        sensitivity   = 0.0, -- -1.0 - 1.0, 0 means no modification.

        repeat_rate   = 40,
        repeat_delay  = 300,
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- hl.window_rule({ name = "steam-input", match = { initial_class = "steam_app_230410" }, allows_input = true })

hl.window_rule({
    name   = "fzf-runner",
    match  = { initial_class = "fzf-runner" },

    float  = true,
    center = true,
    pin    = true,
    size   = "600 380",
})

hl.layer_rule({
    name    = "no-anim-selection",
    match   = { namespace = "selection" },

    no_anim = true,
})

hl.layer_rule({
    name         = "sidebar",
    match        = { namespace = "sidebar" },

    blur         = true,
    ignore_alpha = 0.2825,
})

hl.layer_rule({
    name  = "blur-runner",
    match = { namespace = "runner" },

    blur  = true,
})

hl.layer_rule({
    name  = "blur-notifications",
    match = { namespace = "notifications" },

    blur  = true,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod     = "SUPER"
local mainModCtrl = "SUPER + CTRL"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty -1"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("kitty -1 --app-id fzf-runner fzf-runner"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("lock"))

hl.bind(mainMod .. " + Print",
    hl.dsp.exec_cmd([[grim -c - | wl-copy -n -t image/png; notify-send 'Screenshot copied to the clipboard.']]))
hl.bind(mainModCtrl .. " + Print",
    hl.dsp.exec_cmd(
    [[grim -g "$(slurp)" - | wl-copy -n -t image/png && notify-send 'Screenshot copied to the clipboard.']]))
hl.bind(mainMod .. " + SHIFT + Print",
    hl.dsp.exec_cmd(
    [[grim -g "$(slurp)" - | tesseract - - | wl-copy && notify-send 'OCR result copied to the clipboard.' || notify-send 'OCR failed']]))
hl.bind(mainMod .. " + SHIFT + O",
    hl.dsp.exec_cmd(
    [[wl-paste -t image | tesseract - - | wl-copy && notify-send 'OCR result copied to the clipboard.' || notify-send 'OCR failed']]))
hl.bind(mainModCtrl .. " + S", hl.dsp.exec_cmd("wl-paste -t image | swappy -f -"))

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volumectl -5"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volumectl +5"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("volumectl mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("backlightctl +5"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("backlightctl -5"))

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P", hl.dsp.window.pin())
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))

-- Change scaling
hl.bind(mainModCtrl .. " + H", function() hl.monitor(scaledMonitor) end)
hl.bind(mainModCtrl .. " + L", function() hl.monitor(nativeMonitor) end)

-- Compress/Expand
hl.bind(mainModCtrl .. " + C", function()
    hl.config({ general = { gaps_in = 0, gaps_out = 0 }, decoration = { rounding = 0 } })
end)
hl.bind(mainModCtrl .. " + E", function()
    hl.config({ general = { gaps_in = 5, gaps_out = 10 }, decoration = { rounding = 8 } })
end)

-- Move focus with mainMod + arrow keys
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + " .. dir, hl.dsp.focus({ direction = dir }))
    -- Move window with mainMod + SHIFT + arrow keys
    hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move current workspace to a monitor with mainMod + CTRL + 1-2
hl.bind(mainMod .. " + CTRL + 1", hl.dsp.workspace.move({ monitor = "DP-1" }))
hl.bind(mainMod .. " + CTRL + 2", hl.dsp.workspace.move({ monitor = "DP-2" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Magnify
hl.bind(mainMod .. " + SHIFT + M", function() hl.config({ cursor = { zoom_factor = 2 } }) end)
hl.bind(mainMod .. " + SHIFT + N", function() hl.config({ cursor = { zoom_factor = 1 } }) end)

-- Resize with keyboard
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
    hl.bind("left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

    hl.bind("SHIFT + right", hl.dsp.window.resize({ x = 25, y = 0, relative = true }), { repeating = true })
    hl.bind("SHIFT + left", hl.dsp.window.resize({ x = -25, y = 0, relative = true }), { repeating = true })
    hl.bind("SHIFT + up", hl.dsp.window.resize({ x = 0, y = -25, relative = true }), { repeating = true })
    hl.bind("SHIFT + down", hl.dsp.window.resize({ x = 0, y = 25, relative = true }), { repeating = true })

    hl.bind("escape", hl.dsp.submap("reset"))
end)
