{ meta, ... }:
{
  networking.wg-quick.interfaces.home = meta.titania.vpn;
}
