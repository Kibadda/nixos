{
  ...
}:
let
  # Sensor firmware file name extracted from Lenovo's Windows driver package.
  fwName = "6_07f_lenovo_sm_qm.xpfwext";
in
{
  perSystem =
    { pkgs, ... }:
    let
      lib = pkgs.lib;
    in
    {
      # Patched fork: upstream python-validity has no 06cb:00a2 (match-on-host)
      # support. This branch adds the MoH enrollment/matching pipeline.
      # Revisit when https://github.com/uunicorn/python-validity/pull/261 merges.
      packages.python-validity = pkgs.python3Packages.buildPythonApplication {
        pname = "python-validity";
        version = "0.15-06cb00a2";

        format = "setuptools";

        src = pkgs.fetchFromGitHub {
          owner = "dmitriy-myz";
          repo = "python-validity";
          rev = "81d98fdfb4d0330309887ac63c0c35957c8fdfd6";
          hash = "sha256-eaC5AmJ03IZ97hocHLAJn6/DGH64wRX0BfNoC06y2p0=";
        };

        nativeBuildInputs = [ pkgs.makeWrapper ];

        dependencies = with pkgs.python3Packages; [
          cryptography
          pyusb
          pyyaml
          numpy
          dbus-python
          pygobject3
        ];

        # Tests expect real hardware / upstream CI environment.
        doCheck = false;

        # validity-sensors-firmware shells out to innoextract/find at runtime.
        makeWrapperArgs = [
          "--prefix PATH : ${
            lib.makeBinPath [
              pkgs.innoextract
              pkgs.coreutils
              pkgs.findutils
            ]
          }"
        ];

        meta = {
          description = "Synaptics/Validity fingerprint sensor driver (06cb:00a2 match-on-host support)";
          homepage = "https://github.com/uunicorn/python-validity";
          license = lib.licenses.mit;
          platforms = lib.platforms.linux;
          mainProgram = "validity-sensors-firmware";
        };
      };
    };

  flake.nixosModules.fingerprint =
    {
      config,
      lib,
      pkgs,
      selfpkgs,
      ...
    }:
    let
      validity = selfpkgs.python-validity;

      # Interpreter env for dbus-service (its data_files install is not on PATH).
      validityPython = pkgs.python3.withPackages (ps: [
        selfpkgs.python-validity
        ps.pyusb
        ps.pyyaml
        ps.cryptography
        ps.numpy
        ps.dbus-python
        ps.pygobject3
      ]);

      # Only the D-Bus *policy* is needed from open-fprintd; its packaged
      # D-Bus activation file points at /usr/lib/... and must not be used.
      openFprintdDBusPolicy = pkgs.runCommand "open-fprintd-dbus-policy" { } ''
        mkdir -p $out/share/dbus-1/system.d
        cp ${pkgs.open-fprintd}/share/dbus-1/system.d/net.reactivated.Fprint.conf \
          $out/share/dbus-1/system.d/
      '';

      firmwareScript = pkgs.writeShellScript "python-validity-firmware" ''
        set -eu

        fw="/var/lib/python-validity/${fwName}"
        if [ -s "$fw" ]; then
          exit 0
        fi

        # Only download when the sensor is actually attached.
        found=0
        for dev in /sys/bus/usb/devices/*/; do
          [ "$(cat "$dev/idVendor" 2>/dev/null || true)" = "06cb" ] || continue
          [ "$(cat "$dev/idProduct" 2>/dev/null || true)" = "00a2" ] || continue
          found=1
        done
        if [ "$found" -ne 1 ]; then
          echo "06cb:00a2 not attached, skipping firmware download"
          exit 0
        fi

        ${validity}/bin/validity-sensors-firmware
      '';
    in
    {
      assertions = [
        {
          assertion = !config.services.fprintd.enable;
          message = "services.fprintd must stay disabled: open-fprintd owns net.reactivated.Fprint instead";
        }
      ];

      environment.systemPackages = [
        pkgs.fprintd
        selfpkgs.python-validity
      ];

      # Install D-Bus policy files for both daemons.
      services.dbus.packages = [
        selfpkgs.python-validity
        openFprintdDBusPolicy
      ];

      # fprintd itself is not started; only its PAM module / CLI clients are used.
      services.fprintd.package = pkgs.fprintd;

      # dbus-service and the firmware downloader both expect /var/run/python-validity,
      # which is tmpfs on NixOS. Persist it so firmware + calibration survive reboots.
      systemd.tmpfiles.rules = [
        "d /var/lib/python-validity 0700 root root -"
        "L+ /run/python-validity - - - - /var/lib/python-validity"
      ];

      systemd.services.open-fprintd = {
        description = "Open FPrint daemon";
        wantedBy = [ "multi-user.target" ];
        after = [ "dbus.service" ];
        requires = [ "dbus.service" ];
        serviceConfig = {
          Type = "dbus";
          BusName = "net.reactivated.Fprint";
          ExecStart = "${pkgs.open-fprintd}/lib/open-fprintd/open-fprintd";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };

      systemd.services.python3-validity = {
        description = "python-validity fingerprint driver D-Bus service";
        wantedBy = [ "multi-user.target" ];
        wants = [ "open-fprintd.service" ];
        after = [ "open-fprintd.service" ];
        # First boot downloads firmware; avoid a tight restart loop if offline.
        startLimitIntervalSec = 300;
        startLimitBurst = 10;
        serviceConfig = {
          Type = "simple";
          ExecStartPre = "${firmwareScript}";
          ExecStart = "${validityPython}/bin/python ${validity}/lib/python-validity/dbus-service";
          Restart = "on-failure";
          RestartSec = 2;
        };
        environment = {
          # buildPythonApplication is not picked up by withPackages' env.
          PYTHONPATH = "${validity}/${pkgs.python3.sitePackages}";
        };
      };

      # Upstream udev rule only knows 138a:0090/0097 and 06cb:009a.
      services.udev.extraRules = ''
        ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="06cb", ATTRS{idProduct}=="00a2", ATTR{power/control}="on", TAG+="systemd", ENV{SYSTEMD_WANTS}+="python3-validity.service"
      '';

      # Fingerprint auth is PAM-only: the driver/daemons are compositor-agnostic.
      # `login` covers the tty login queue that starts hyprland on tty1.
      security.pam.services.login.fprintAuth = true;

      # Screen unlock is per-locker, not per-compositor. Uncomment the service
      # matching your lock screen (PAM name = locker binary name):
      #   hyprlock  -> security.pam.services.hyprlock.fprintAuth
      #   swaylock  -> security.pam.services.swaylock.fprintAuth
      #   gtklock   -> security.pam.services.gtklock.fprintAuth
      # GNOME/GDM instead need gdm-password / gdm-launch-environment.
      #
      # security.pam.services.hyprlock.fprintAuth = true;
    };
}
