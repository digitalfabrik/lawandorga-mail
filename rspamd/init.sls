# lawandorga-mail/rspamd
# Installs and configures Rspamd as the mail filter (DKIM signing/verification,
# SPF, DMARC, spam scoring, bayes, reputation, greylisting and antivirus).
# Replaces the former OpenDKIM milter and postfix-policyd-spf-python service.
#
# Postfix talks to Rspamd via the proxy/milter worker on localhost:11332
# (see ../postfix/files/main.cf.j2, "Milter" section).

# -------
# APT repository
# -------

rspamd-repo-key:
  cmd.run:
    - name: bash -c "curl -fsSL https://rspamd.com/apt-stable/gpg.key | gpg --dearmor -o /usr/share/keyrings/rspamd.gpg"
    - creates: /usr/share/keyrings/rspamd.gpg

rspamd:
  pkgrepo.managed:
    - humanname: rspamd
    - name: deb [signed-by=/usr/share/keyrings/rspamd.gpg] http://rspamd.com/apt-stable/ {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/rspamd.list
    - require:
      - cmd: rspamd-repo-key
    - require_in:
      - pkg: rspamd

  pkg.latest:
    - refresh: True
    - pkgs:
      - rspamd
      - redis-server
      - clamav-daemon

# -------
# Redis (bayes / reputation / greylisting backend)
# -------

rspamd-redis-service:
  service.running:
    - name: redis-server.service
    - enable: True
    - require:
      - pkg: rspamd

# -------
# ClamAV
# -------

# Allow the _rspamd user to access the clamd control socket.
rspamd-clamav-group-member:
  group.present:
    - name: clamav
    - require:
      - pkg: rspamd
    - addusers:
      - _rspamd

# -------
# Configuration
# -------

rspamd-redis:
  file.managed:
    - name: /etc/rspamd/local.d/redis.conf
    - source: salt://lawandorga-mail/rspamd/files/redis.conf
    - watch_in:
      - rspamd-service

rspamd-bayes:
  file.managed:
    - name: /etc/rspamd/local.d/classifier-bayes.conf
    - source: salt://lawandorga-mail/rspamd/files/classifier-bayes.conf
    - watch_in:
      - rspamd-service

rspamd-upstream-spam-flag:
  file.managed:
    - name: /etc/rspamd/override.d/headers_group.conf
    - source: salt://lawandorga-mail/rspamd/files/headers_group.conf
    - watch_in:
      - rspamd-service

rspamd-dkim:
  file.managed:
    - name: /etc/rspamd/local.d/dkim_signing.conf
    - source: salt://lawandorga-mail/rspamd/files/dkim-signing.conf.j2
    - template: jinja
    - watch_in:
      - rspamd-service

rspamd-custom-rules:
  file.managed:
    - name: /etc/rspamd/rspamd.local.lua
    - source: salt://lawandorga-mail/rspamd/files/rspamd.local.lua
    - watch_in:
      - rspamd-service

rspamd-whitelist:
  file.managed:
    - name: /etc/rspamd/local.d/whitelist.conf
    - source: salt://lawandorga-mail/rspamd/files/whitelist.conf
    - watch_in:
      - rspamd-service

rspamd-domain-allowlist:
  file.managed:
    - name: /etc/rspamd/domain-allowlist.map
    - source: salt://lawandorga-mail/rspamd/files/domain-allowlist.map
    - watch_in:
      - rspamd-service

rspamd-domain-blocklist:
  file.managed:
    - name: /etc/rspamd/domain-blocklist.map
    - source: salt://lawandorga-mail/rspamd/files/domain-blocklist.map
    - watch_in:
      - rspamd-service

rspamd-ip-reputation:
  file.managed:
    - name: /etc/rspamd/local.d/reputation.conf
    - source: salt://lawandorga-mail/rspamd/files/reputation.conf
    - watch_in:
      - rspamd-service

rspamd-antivirus:
  file.managed:
    - name: /etc/rspamd/local.d/antivirus.conf
    - source: salt://lawandorga-mail/rspamd/files/antivirus.conf
    - watch_in:
      - rspamd-service

rspamd-custom-groups:
  file.managed:
    - name: /etc/rspamd/local.d/groups.conf
    - source: salt://lawandorga-mail/rspamd/files/groups.conf
    - watch_in:
      - rspamd-service

rspamd-policies-group:
  file.managed:
    - name: /etc/rspamd/local.d/policies_group.conf
    - source: salt://lawandorga-mail/rspamd/files/policies_group.conf
    - watch_in:
      - rspamd-service

rspamd-logging:
  file.managed:
    - name: /etc/rspamd/local.d/logging.inc
    - source: salt://lawandorga-mail/rspamd/files/logging.inc
    - watch_in:
      - rspamd-service

rspamd-milter:
  file.managed:
    - name: /etc/rspamd/local.d/milter_headers.conf
    - source: salt://lawandorga-mail/rspamd/files/milter_headers.conf
    - watch_in:
      - rspamd-service

rspamd-options:
  file.managed:
    - name: /etc/rspamd/local.d/options.inc
    - source: salt://lawandorga-mail/rspamd/files/options.inc
    - watch_in:
      - rspamd-service

rspamd-worker-normal:
  file.managed:
    - name: /etc/rspamd/local.d/worker-normal.inc
    - source: salt://lawandorga-mail/rspamd/files/worker-normal.inc
    - watch_in:
      - rspamd-service

rspamd-worker-proxy:
  file.managed:
    - name: /etc/rspamd/local.d/worker-proxy.inc
    - source: salt://lawandorga-mail/rspamd/files/worker-proxy.inc
    - watch_in:
      - rspamd-service

rspamd-max-score-conf:
  file.managed:
    - name: /etc/rspamd/override.d/whitelist_group.conf
    - contents: |
        max_score = 12.0;
    - watch_in:
      - rspamd-service

rspamd-greylisting-conf:
  file.managed:
    - name: /etc/rspamd/override.d/greylist.conf
    - source: salt://lawandorga-mail/rspamd/files/greylist.conf
    - watch_in:
      - rspamd-service

rspamd-override-actions:
  file.managed:
    - name: /etc/rspamd/override.d/actions.conf
    - source: salt://lawandorga-mail/rspamd/files/override-actions.conf
    - watch_in:
      - rspamd-service

# -------
# DKIM signing key
# -------
#  - Migrated from OpenDKIM; stored in Passbolt (mail_dkim_key_uuid) and the
#    same selector (mail_dkim_selector) is kept so the published DNS DKIM
#    record stays valid.

rspamd-dkim-key:
  file.managed:
    - name: /var/lib/rspamd/dkim/signing.key
    - source: salt://lawandorga-mail/rspamd/files/dkim-signing.key.j2
    - template: jinja
    - user: _rspamd
    - group: _rspamd
    - mode: '0440'
    - makedirs: True
    # Keep the private key out of the state output.
    - show_changes: False
    - require:
      - pkg: rspamd
    - watch_in:
      - rspamd-service

rspamd-dkim-create:
  file.managed:
    - name: /usr/local/bin/dkim_create.sh
    - source: salt://lawandorga-mail/rspamd/files/dkim_create.sh
    - mode: '0755'

# -------
# Service
# -------

rspamd-service:
  service.running:
    - name: rspamd.service
    - enable: True
    - require:
      - pkg: rspamd
      - service: rspamd-redis-service
      - group: rspamd-clamav-group-member
      - file: rspamd-dkim-key
