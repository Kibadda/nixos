{
  meta,
  ...
}:
{
  users.users.${meta.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$t2GM2AFGTwx5HL1S$NuDSMSjd93Cm6Ud3uBMtaGVvFGdnJzgVlPOXYRWEras8eqeYhuSPuLA.lfBBFgWpTLEBOVlf2VlKoJqPvGZbC1";
  };
}
