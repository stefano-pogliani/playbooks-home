# Todo List
There are some improvements to make and some changes that are required.
This list hopes to keep track so they get done.

  1. Custom DNS for internal network:
     1. Install unbound on server.
     2. Configure server to use itself for DNS (fallback to router).
     2. Configure (my) clients to use server for DNS (fallback to router).
     3. Maybe one day? make server the default DNS.
  2. Replace acmetool (because protocol support):
     1. Renew certs with the existing solution (minimize risk of certs unavailability while migrating).
     2. Create an `http-redirect` service (nginx on port 80 with static config; container?).
     3. Figure out how to pass the list of domains from authgateway to certbot (authgateway command to render template with context?).
     4. Use certbot manual mode with HTTP challange (conteiner?).
     5. Remove acmetool.
  3. Update MongoDB to 4.2 && PostgreSQL to 12?
  4. Fix Grafana deprecation warning about phantomJS.
  5. Additional metrics collection:
      * Postfix exporter (number of emails sent).
      * SystemD (depends on metrics, with focus on timers).
      * NextCloud (PHP?).
      * Podman metrics?
      * FireFly-III/PHP?
      * Wekan (Node?/Meteor?).
