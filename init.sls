include:
  - lawandorga-mail.bash-scripts-aux
  - lawandorga-mail.delete-old-userdata
  - lawandorga-mail.dovecot
  - lawandorga-mail.firewall
  - nginx
  - lawandorga-mail.ntp-client
  - lawandorga-mail.postfix
  - lawandorga-mail.rspamd
  - lawandorga-mail.roundcube
  # Certificates are obtained/renewed by the generic `nginx` state via certbot
  # (see the `letsencrypt` pillar); the former acme-tiny-era `tls-acme` and
  # `tls-key` states are retired.
  - lawandorga-mail.tls-dhparams
  - lawandorga-mail.unbound
  - zfs
  - zfs-snapshot
