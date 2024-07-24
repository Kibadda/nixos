{ pkgs, ... }: {
  enable = true;

  font = {
    name = "JetBrainsMono Nerd Font";
    size = 10;
  };

  extraConfig = ''
    modify_font cell_height 105%
  '';

  keybindings = {
    "kitty_mod+q" = "noop";
    "kitty_mod+l" = "noop";
    "kitty_mod+h" = "launch --type=window --cwd=current --location=hsplit";
    "kitty_mod+b" = "launch --type=window --cwd=current --location=vsplit";
    "kitty_mod+n" = "launch --type=window --cwd=current --location=split";
    "kitty_mod+e" = "layout_action rotate";
    "kitty_mod+z" = "toggle_layout stack";
    "ctrl+h" = "kitten pass_keys.py left ctrl+h";
    "ctrl+j" = "kitten pass_keys.py left ctrl+j";
    "ctrl+k" = "kitten pass_keys.py left ctrl+k";
    "ctrl+l" = "kitten pass_keys.py left ctrl+l";
  };

  settings = {
    sync_to_monitor = "no";
    disable_ligatures = "never";
    enable_audio_bell = "no";
    dynamic_background_opacity = true;
    cursor_shape = "block";
    cursor_blink_interval = 0;
    background_opacity = "0.9";
    window_padding_width = 5;
    enabled_layouts = "splits,stack";

    allow_remote_control = "socket-only";
    listen_on = "unix:/tmp/kitty";

    tab_bar_min_tabs = 1;
    tab_bar_edge = "bottom";
    tab_bar_style = "powerline";
    tab_powerline_style = "slanted";

    foreground = "#C6D0F5";
    background = "#303446";
    selection_foreground = "#303446";
    selection_background = "#F2D5CF";
    cursor = "#F2D5CF";
    cursor_text_color = "#303446";
    url_color = "#F2D5CF";
    active_border_color = "#BABBF1";
    inactive_border_color = "#737994";
    bell_border_color = "#E5C890";
    wayland_titlebar_color = "system";
    macos_titlebar_color = "system";
    active_tab_foreground = "#232634";
    active_tab_background = "#CA9EE6";
    inactive_tab_foreground = "#C6D0F5";
    inactive_tab_background = "#292C3C";
    tab_bar_background = "#232634";
    mark1_foreground = "#303446";
    mark1_background = "#BABBF1";
    mark2_foreground = "#303446";
    mark2_background = "#CA9EE6";
    mark3_foreground = "#303446";
    mark3_background = "#85C1DC";
    color0 = "#51576D";
    color8 = "#626880";
    color1 = "#E78284";
    color9 = "#E78284";
    color2 = "#A6D189";
    color10 = "#A6D189";
    color3 = "#E5C890";
    color11 = "#E5C890";
    color4 = "#8CAAEE";
    color12 = "#8CAAEE";
    color5 = "#F4B8E4";
    color13 = "#F4B8E4";
    color6 = "#81C8BE";
    color14 = "#81C8BE";
    color7 = "#B5BFE2";
    color15 = "#A5ADCE";
  };

  shellIntegration = {
    mode = "no-cursor";
  };
}
