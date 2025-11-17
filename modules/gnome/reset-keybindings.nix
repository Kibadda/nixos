{
  lib,
}:
{
  "org/gnome/shell/keybindings" = {
    show-screen-recording-ui = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
  };

  "org/gnome/settings-daemon/plugins/media-keys" = {
    battery-status = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    battery-status-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    calculator = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    calculator-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    control-center = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    control-center-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    decrease-text-size = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    eject = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    eject-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    email = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    email-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    help = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    hibernate = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    hibernate-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    home = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    home-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    increase-text-size = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    keyboard-brightness-down = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    keyboard-brightness-down-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    keyboard-brightness-toggle = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    keyboard-brightness-toggle-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    keyboard-brightness-up = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    keyboard-brightness-up-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    logout = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    magnifier = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    magnifier-zoom-in = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    magnifier-zoom-out = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    media = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    media-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    mic-mute = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    mic-mute-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    next-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    on-screen-keyboard = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    screenreader = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    screensaver = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
  };

  "org/gnome/desktop/wm/keybindings" = {
    activate-window-menu = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    always-on-top = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    begin-move = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    begin-resize = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    cycle-group = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    cycle-group-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    cycle-panels = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    cycle-windows = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    cycle-windows-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    lower = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    minimize = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-center = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-corner-ne = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-corner-nw = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-corner-se = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-corner-sw = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-monitor-down = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-left = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-right = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-monitor-up = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-side-e = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-side-n = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-side-s = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-side-w = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-5 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-6 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-7 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-8 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-9 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-10 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-11 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-12 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    maximize-horizontally = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    maximize-vertically = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-down = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-up = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    move-to-workspace-last = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    panel-run-dialog = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    raise = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    raise-or-lower = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    set-spew-mark = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    show-desktop = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-applications = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-applications-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-group = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-group-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-input-source = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-input-source-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-panels = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-panels-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-5 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-6 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-7 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-8 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-9 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-10 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-11 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-12 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-down = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-left = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-right = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-up = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    switch-to-workspace-last = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    maximize = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    toggle-on-all-workspaces = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    unmaximize = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
  };

  "org/gnome/mutter/wayland/keybindings" = {
    restore-shortcuts = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
  };

  "org/gnome/shell/keybindings" = {
    focus-active-notification = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    toggle-quick-settings = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    toggle-application-view = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
    toggle-message-tray = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
  };
}
