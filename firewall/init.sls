# lawandorga-mail/firewall
# Installs and configures nftables with auxiliary definitions.
#  - Inbound: default drop, with an allowlist (see `files/definitions/portsets.nft`,
#    extended by the postfix and dovecot states).
#  - Outbound: unrestricted (see `files/output/base.nft`).
#  - Forwarding: dropped.

firewall-nftables-pkg:
  pkg.installed:
    - pkgs:
      - nftables
      - netbase

firewall-nftables-aux-definitions-dir:
  file.directory:
    - name: /etc/nftables/definitions
    - mode: '0755'
    - makedirs: true

firewall-nftables-aux-input-dir:
  file.directory:
    - name: /etc/nftables/input
    - mode: '0755'
    - makedirs: true

firewall-nftables-aux-output-dir:
  file.directory:
    - name: /etc/nftables/output
    - mode: '0755'
    - makedirs: true

firewall-nftables-aux-forward-dir:
  file.directory:
    - name: /etc/nftables/forward
    - mode: '0755'
    - makedirs: true

firewall-nftables-custom-dir:
  file.directory:
    - name: /etc/nftables/custom
    - mode: '0755'
    - makedirs: true

firewall-nftables-def-addresses:
  file.managed:
    - name: /etc/nftables/definitions/addresses.nft
    - source: salt://lawandorga-mail/firewall/files/definitions/addresses.nft
    - mode: '0644'
    - require:
      - firewall-nftables-aux-definitions-dir
    - watch_in:
      - service: firewall-nftables-service

firewall-nftables-def-ports:
  file.managed:
    - name: /etc/nftables/definitions/ports.nft
    - source: salt://lawandorga-mail/firewall/files/definitions/ports.nft
    - mode: '0644'
    - require:
      - firewall-nftables-aux-definitions-dir
    - watch_in:
      - service: firewall-nftables-service

firewall-nftables-def-portsets:
  file.managed:
    - name: /etc/nftables/definitions/portsets.nft
    - source: salt://lawandorga-mail/firewall/files/definitions/portsets.nft
    - mode: '0644'
    - require:
      - firewall-nftables-aux-definitions-dir
    - watch_in:
      - service: firewall-nftables-service

firewall-nftables-input-base:
  file.managed:
    - name: /etc/nftables/input/base.nft
    - source: salt://lawandorga-mail/firewall/files/input/base.nft
    - mode: '0644'
    - require:
      - firewall-nftables-aux-input-dir
    - watch_in:
      - service: firewall-nftables-service

firewall-nftables-input-allowlist:
  file.managed:
    - name: /etc/nftables/input/allowlist.part.nft
    - source: salt://lawandorga-mail/firewall/files/input/allowlist.part.nft
    - mode: '0644'
    - require:
      - firewall-nftables-aux-input-dir
    - watch_in:
      - service: firewall-nftables-service

firewall-nftables-output-base:
  file.managed:
    - name: /etc/nftables/output/base.nft
    - source: salt://lawandorga-mail/firewall/files/output/base.nft
    - mode: '0644'
    - require:
      - firewall-nftables-aux-output-dir
    - watch_in:
      - service: firewall-nftables-service

firewall-nftables-forward-none:
  file.managed:
    - name: /etc/nftables/forward/none.nft
    - source: salt://lawandorga-mail/firewall/files/forward/none.nft
    - mode: '0644'
    - require:
      - firewall-nftables-aux-forward-dir
    - watch_in:
      - service: firewall-nftables-service

# Remove files from the retired outbound port allowlist.
#  - Egress is unrestricted, see `files/output/base.nft`.
#  - `custom/ports-database.nft` MUST go: `/etc/nftables.conf` globs
#    `custom/*`, and the stale file references the removed out_outbound chain,
#    which would make the whole ruleset fail to load.
firewall-nftables-retired-outbound-files:
  file.absent:
    - names:
      - /etc/nftables/custom/ports-database.nft
      - /etc/nftables/output/allowlist.part.nft
    - watch_in:
      - service: firewall-nftables-service

firewall-nftables-conf:
  file.managed:
    - name: /etc/nftables.conf
    - source: salt://lawandorga-mail/firewall/files/nftables.conf
    - mode: '0755'
    - require:
      - firewall-nftables-def-addresses
      - firewall-nftables-def-ports
      - firewall-nftables-def-portsets
      - firewall-nftables-input-base
      - firewall-nftables-input-allowlist
      - firewall-nftables-output-base
      - firewall-nftables-forward-none
      - firewall-nftables-retired-outbound-files
    - watch_in:
      - service: firewall-nftables-service

firewall-nftables-service:
  service.running:
    - name: nftables
    - enable: true
    - require:
      - firewall-nftables-pkg
      - firewall-nftables-conf
