# Todo List
There are some improvements to make and some changes that are required.
This list hopes to keep track so they get done.

  1. Configure public access back:
     * Obtain IP from ISP.
     * Set up port forwarding on routers.
     * Update DNS.
  2. Investigate/Move to Zero Trust solutions:
     * https://www.pomerium.io/
     * https://zero.pritunl.com/
  3. Replace acmetool (because protocol support):
     1. Wait until server has public IP again.
     2. Install certbot.
     3. Configure as needed.
     4. Remove acmetool (also from server).
     5. Apply certbot version to server.
  4. Update MongoDB to 4.2 && PostgreSQL to 12?
  5. Fix Grafana deprecation warning about phantomJS.
  6. Additional metrics collection:
      * Postfix exporter (number of emails sent).
      * SystemD (depends on metrics, with focus on timers).
      * NextCloud (PHP?).
      * Podman metrics?
      * FireFly-III/PHP?
      * Wekan (Node?/Meteor?).
