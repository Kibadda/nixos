hl.monitor {
  output = "eDP-1",
  scale = 1,
  position = "0x0",
  mode = "1920x1080@60",
}

hl.config {
  input = {
    kb_layout = "de",
    kb_options = "caps:swapescape",
    numlock_by_default = true,

    touchpad = {
      natural_scroll = true,
      tap_to_click = true,
      disable_while_typing = true,
    },
  },

  general = {
    border_size = 1,
    gaps_in = 5,
    gaps_out = 5,
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },

  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },
}

hl.window_rule {
  match = {
    class = "com.kibadda.AdwPinentry",
  },
  float = true,
  center = true,
  dim_around = true,
}

hl.window_rule {
  match = {
    class = "com.gabm.satty",
  },
  float = true,
  center = true,
}

hl.env("GTK_THEME", "dark")

hl.on("hyprland.start", function()
  hl.exec_cmd "hyprpaper"
end)

local function super(key, dispatcher)
  hl.bind("SUPER + " .. key, dispatcher)
end
local function shift(key, dispatcher)
  super("SHIFT + " .. key, dispatcher)
end

super("Return", hl.dsp.exec_cmd "kitty")
super("B", hl.dsp.exec_cmd "firefox")
shift("B", hl.dsp.exec_cmd "firefox --private-window")

for i = 1, 5 do
  super(i, hl.dsp.focus { workspace = i })
  shift(i, hl.dsp.window.move { workspace = i })
end

for bind, direction in pairs { h = "left", j = "down", k = "up", l = "right" } do
  super(bind, hl.dsp.focus { direction = direction })
  shift(bind, hl.dsp.window.move { direction = direction })
end

super("Space", hl.dsp.window.float { action = "toggle" })
shift("Space", hl.dsp.window.fullscreen { mode = "fullscreen", action = "toggle" })
super("Q", hl.dsp.window.close())
shift("Q", hl.dsp.window.kill())

super("D", hl.dsp.exec_cmd "hyprlauncher")

hl.bind("Print", hl.dsp.exec_cmd 'grim - "$(slurp)" - | wl-copy')
hl.bind(
  "SUPER + Print",
  hl.dsp.exec_cmd "grim - | satty -f - --copy-command wl-copy -o ~/Pictures/Screenshots/%Y-%M-%D_%H:%M:%S.png"
)

hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+",
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
  { locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd "brightnessctl -e4 -n2 set 5%+", { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd "brightnessctl -e4 -n2 set 5%-", { locked = true, repeating = true })
