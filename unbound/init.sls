# lawandorga-mail/unbound
# Installs and configures Unbound as a local DNSSEC-validating caching resolver.

unbound-pkg:
  pkg.installed:
    - pkgs:
      - unbound
      - dns-root-data

# Custom systemd service unit overrides the Debian-packaged one.
unbound-systemd-unit:
  file.managed:
    - name: /etc/systemd/system/unbound.service
    - source: salt://lawandorga-mail/unbound/files/unbound.service
    - mode: '0644'
    - require:
      - unbound-pkg
    - watch_in:
      - service: unbound-service

unbound-systemd-reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: unbound-systemd-unit

unbound-default:
  file.managed:
    - name: /etc/default/unbound
    - source: salt://lawandorga-mail/unbound/files/unbound.default
    - mode: '0644'

# Main unbound config dir and conf/ subdirectory.
unbound-conf-dir:
  file.directory:
    - name: /etc/unbound/conf
    - mode: '0755'
    - makedirs: true

unbound-conf:
  file.managed:
    - name: /etc/unbound/unbound.conf
    - source: salt://lawandorga-mail/unbound/files/unbound.conf
    - mode: '0644'
    - require:
      - unbound-conf-dir
    - watch_in:
      - service: unbound-service

unbound-conf-private-addresses:
  file.managed:
    - name: /etc/unbound/conf/private-addresses.conf
    - source: salt://lawandorga-mail/unbound/files/conf/private-addresses.conf
    - mode: '0644'
    - require:
      - unbound-conf-dir
    - watch_in:
      - service: unbound-service

unbound-conf-forward:
  file.managed:
    - name: /etc/unbound/conf/forward.conf
    - source: salt://lawandorga-mail/unbound/files/conf/forward.conf
    - mode: '0644'
    - require:
      - unbound-conf-dir
    - watch_in:
      - service: unbound-service

# root_key subdirectory must be writable by the unbound user
# (chroot setup requires it).
unbound-root-key-dir:
  file.directory:
    - name: /var/lib/unbound/root_key
    - user: unbound
    - group: unbound
    - mode: '0755'
    - makedirs: true
    - require:
      - unbound-pkg

# resolv.conf pointing to local unbound.
unbound-resolv-conf:
  file.managed:
    - name: /etc/resolv.conf
    - contents: |
        nameserver 127.0.0.1
    - mode: '0644'

unbound-service:
  service.running:
    - name: unbound
    - enable: true
    - require:
      - unbound-pkg
      - unbound-conf
      - unbound-root-key-dir
      - unbound-systemd-reload
