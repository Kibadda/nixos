{
  secrets,
  ...
}:
{
  flake.nixosModules.n8n =
    {
      pkgs,
      ...
    }:
    {
      kibadda.services.n8n = {
        description = "Automation";
        subdomain = "automation";
        port = 5678;
        auth = "forward";
        section = "Tools";
      };

      services = {
        n8n = {
          enable = true;
          environment = {
            DB_TYPE = "postgresdb";
            DB_POSTGRESDB_HOST = "/run/postgresql";
            DB_POSTGRESDB_DATABASE = "n8n";
            DB_POSTGRESDB_USER = "n8n";
            N8N_PORT = 5678;
            N8N_SSO_HOSTNAME = "automation.${secrets.pi.domain}";
            WEBHOOK_URL = "https://automation.${secrets.pi.domain}";
            N8N_FORWARD_AUTH_HEADER = "Remote-Email";
            N8N_HIRING_BANNER_ENABLED = "false";
            N8N_LICENSE_ACTIVATION_KEY = secrets.pi.n8n.license;
            EXTERNAL_HOOK_FILES =
              let
                hooksFile =
                  pkgs.writeText "n8n-hooks.js"
                    #js
                    ''
                      const fs = require('fs')
                      const {resolve} = require('path')
                      const n8nBasePath = '${pkgs.n8n}/lib/n8n';
                      const pnpmDir = resolve(n8nBasePath, 'node_modules/.pnpm');
                      const routerDir = fs.readdirSync(pnpmDir).find(dir => dir.startsWith('router@'));
                      const Layer = require(resolve(pnpmDir, routerDir, 'node_modules/router/lib/layer'));
                      const {issueCookie} = require(resolve(n8nBasePath, 'packages/cli/dist/auth/jwt'));
                      const ignoreAuthRegexp = /^\/(assets|healthz|webhook|rest\/oauth2-credential)/

                      module.exports = {
                        n8n: {
                          ready: [
                            async function ({app}, config) {
                              const {stack} = app.router
                              const index = stack.findIndex((l) => l.name === 'cookieParser')
                              stack.splice(index + 1, 0, new Layer('/', {
                                strict: false,
                                end: false
                              }, async (req, res, next) => {
                                // skip if URL is ignored
                                if (ignoreAuthRegexp.test(req.url)) return next()

                                // skip if user management is not set up yet
                                if (!config.get('userManagement.isInstanceOwnerSetUp', false)) return next()

                                // skip if cookie already exists
                                if (req.cookies?.['n8n-auth']) return next()

                                // if N8N_FORWARD_AUTH_HEADER is not set, skip
                                if (!process.env.N8N_FORWARD_AUTH_HEADER) return next()

                                const allowedHost = process.env.N8N_SSO_HOSTNAME || 'automation.${secrets.pi.domain}';
                                if (req.headers.host !== allowedHost) return next()

                                // if N8N_FORWARD_AUTH_HEADER header is not found, skip
                                const email = req.headers[process.env.N8N_FORWARD_AUTH_HEADER.toLowerCase()]
                                if (!email) return next()

                                // search for user with email
                                const user = await this.dbCollections.User.findOneBy({email})
                                if (!user) {
                                  res.statusCode = 401
                                  res.end(`User ''${email} not found, please have an admin invite the user first.`)
                                  return
                                }

                                if (!user.role) {
                                  user.role = {}
                                }

                                // issue cookie if all is OK
                                issueCookie(res, user)
                                return next()
                              }))
                            },
                          ],
                        },
                      }
                    '';
              in
              "${hooksFile}";
          };
        };

        postgresql = {
          ensureDatabases = [ "n8n" ];
          ensureUsers = [
            {
              name = "n8n";
              ensureDBOwnership = true;
            }
          ];
        };
      };
    };
}
