# NTP client configuration (systemd-timesyncd).
# Corresponds to Ansible role: common/ntp-client

ntp-client-install:
  pkg.installed:
    - name: systemd-timesyncd

ntp-client-service:
  service.running:
    - name: systemd-timesyncd
    - enable: True
    - require:
      - pkg: ntp-client-install
