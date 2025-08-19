{
  secrets,
  ...
}:
{
  oberon = {
    nginx."${secrets.pi.n8n.domain}" = {
      restrict-access = true;
      host = "10.0.0.4";
      port = 5678;
    };
  };
}
