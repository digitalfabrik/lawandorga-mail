# lawandorga-mail/dovecot
# Installs and configures the Dovecot IMAP/LMTP server.
# Corresponds to Ansible roles: mail/dovecot, mail/dovecot/sieve

{% set m = pillar['lawandorga_mail'] %}

# -------
# Packages
# -------

dovecot-packages:
  pkg.installed:
    - pkgs:
      - dovecot-core
      - dovecot-pgsql
      - dovecot-lmtpd
      - dovecot-imapd
      - dovecot-sieve

# -------
# Users / Groups
# -------

dovecot-group-vmail:
  group.present:
    - name: vmail
    - gid: 525
    - system: True

dovecot-user-vmail:
  user.present:
    - name: vmail
    - uid: 525
    - gid: 525
    - groups:
      - vmail
    - home: /var/mail
    - createhome: False
    - shell: /usr/sbin/nologin
    - system: True
    - require:
      - group: dovecot-group-vmail

# -------
# Dovecot config directories
# -------

dovecot-confdir-root:
  file.directory:
    - name: /etc/dovecot/conf
    - user: root
    - group: root
    - mode: '0755'

dovecot-confdir-explicit:
  file.directory:
    - name: /etc/dovecot/conf/explicit
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: dovecot-confdir-root

dovecot-confdir-implicit:
  file.directory:
    - name: /etc/dovecot/conf/implicit
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: dovecot-confdir-root

dovecot-confdir-external:
  file.directory:
    - name: /etc/dovecot/conf/external
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: dovecot-confdir-root

dovecot-confdir-explicit-base:
  file.directory:
    - name: /etc/dovecot/conf/explicit/base
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: dovecot-confdir-explicit

dovecot-confdir-snippets:
  file.directory:
    - name: /etc/dovecot/conf/explicit/snippet
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: dovecot-confdir-explicit

dovecot-confdir-implicit-global:
  file.directory:
    - name: /etc/dovecot/conf/implicit/global
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: dovecot-confdir-implicit

# -------
# Mail storage directories
# -------

dovecot-storage-base-dir:
  file.directory:
    - name: /var/mail/virtual
    - user: vmail
    - group: vmail
    - mode: '0700'
    - require:
      - user: dovecot-user-vmail

dovecot-storage-dynamic-accounts-dir:
  file.directory:
    - name: {{ m['mail_dovecot_storage_dynamic_accounts_dir'] }}
    - user: vmail
    - group: vmail
    - mode: '0700'
    - require:
      - file: dovecot-storage-base-dir

dovecot-storage-static-accounts-dir:
  file.directory:
    - name: {{ m['mail_dovecot_storage_static_accounts_dir'] }}
    - user: vmail
    - group: vmail
    - mode: '0700'
    - require:
      - file: dovecot-storage-base-dir

dovecot-storage-admin-account-dir:
  file.directory:
    - name: {{ m['mail_dovecot_storage_admin_account_dir'] }}
    - user: vmail
    - group: vmail
    - mode: '0700'
    - require:
      - file: dovecot-storage-static-accounts-dir

# -------
# Main dovecot config
# -------

dovecot-conf:
  file.managed:
    - name: /etc/dovecot/dovecot.conf
    - source: salt://lawandorga-mail/dovecot/files/dovecot.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: dovecot-packages

# -------
# Base config files
# -------

dovecot-conf-services:
  file.managed:
    - name: /etc/dovecot/conf/explicit/base/services.conf
    - source: salt://lawandorga-mail/dovecot/files/base/services.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-confdir-explicit-base

dovecot-conf-tls:
  file.managed:
    - name: /etc/dovecot/conf/explicit/base/tls.conf
    - source: salt://lawandorga-mail/dovecot/files/base/tls.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-confdir-explicit-base

dovecot-conf-auth:
  file.managed:
    - name: /etc/dovecot/conf/explicit/base/auth.conf
    - source: salt://lawandorga-mail/dovecot/files/base/auth.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-confdir-explicit-base

dovecot-conf-logging:
  file.managed:
    - name: /etc/dovecot/conf/explicit/base/logging.conf
    - source: salt://lawandorga-mail/dovecot/files/base/logging.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-confdir-explicit-base

dovecot-conf-mail-storage:
  file.managed:
    - name: /etc/dovecot/conf/explicit/base/mail-storage.conf
    - source: salt://lawandorga-mail/dovecot/files/base/mail-storage.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-confdir-explicit-base

dovecot-conf-mailboxes:
  file.managed:
    - name: /etc/dovecot/conf/explicit/base/mailboxes.conf
    - source: salt://lawandorga-mail/dovecot/files/base/mailboxes.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-confdir-explicit-base

dovecot-conf-lmtp:
  file.managed:
    - name: /etc/dovecot/conf/explicit/base/lmtp.conf
    - source: salt://lawandorga-mail/dovecot/files/base/lmtp.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-confdir-explicit-base

dovecot-conf-imap:
  file.managed:
    - name: /etc/dovecot/conf/explicit/base/imap.conf
    - source: salt://lawandorga-mail/dovecot/files/base/imap.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-confdir-explicit-base

# -------
# Auth external config files (restricted access — contain SQL password)
# -------

dovecot-conf-sql-connection:
  file.managed:
    - name: /etc/dovecot/conf/external/sql-connection.conf.ext
    - source: salt://lawandorga-mail/dovecot/files/auth-ext/sql-connection.conf.ext.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: dovecot
    - mode: '0640'
    # Keep the database password out of the state output.
    - show_changes: False
    - require:
      - file: dovecot-confdir-external
      - pkg: dovecot-packages

# Remove the pre-2.4 per-database SQL files.
#  - In Dovecot 2.4 the connection is defined once (sql-connection.conf.ext)
#    and the queries live inline in the passdb/userdb blocks of
#    base/auth.conf.  These old files contained the database password.
dovecot-conf-sql-legacy-absent:
  file.absent:
    - names:
      - /etc/dovecot/conf/external/sql-common.conf.ext
      - /etc/dovecot/conf/external/sql-adminauth.conf.ext
      - /etc/dovecot/conf/external/sql-groupauth.conf.ext

dovecot-conf-static-users-passwd:
  file.managed:
    - name: /etc/dovecot/conf/external/static-users.passwd
    - source: salt://lawandorga-mail/dovecot/files/auth-ext/static-users.passwd.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: dovecot
    - mode: '0640'
    - require:
      - file: dovecot-confdir-external
      - pkg: dovecot-packages

# -------
# Implicit global placeholder (required by dovecot.conf include)
# -------

dovecot-conf-implicit-global-empty:
  file.managed:
    - name: /etc/dovecot/conf/implicit/global/_empty.conf
    - contents: "# Placeholder.\n"
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-confdir-implicit-global

# -------
# LMTP mail plugins snippet (written here as empty; sieve appends a line)
# -------

dovecot-conf-lmtp-mail-plugins:
  file.managed:
    - name: /etc/dovecot/conf/explicit/snippet/lmtp-mail-plugins.conf
    - contents: |
        # Enable the sieve plugin for LMTP delivery.
        #  - Dovecot 2.4: `mail_plugins` is a Boolean List; the old
        #    `mail_plugins = $mail_plugins sieve` self-reference is no longer
        #    needed.
        #  - This snippet is included inside `protocol lmtp { }` (see
        #    base/lmtp.conf), so it scopes the plugin to LMTP.
        mail_plugins {
          sieve = yes
        }
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-confdir-snippets

# -------
# Sieve plugin config
# -------

dovecot-conf-sieve:
  file.managed:
    - name: /etc/dovecot/conf/implicit/global/sieve.conf
    - source: salt://lawandorga-mail/dovecot/files/sieve/sieve.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-confdir-implicit-global

dovecot-logrotate-sieve:
  file.managed:
    - name: /etc/logrotate.d/dovecot-sieve
    - source: salt://lawandorga-mail/dovecot/files/sieve/logrotate.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'

# -------
# sysctl config
# -------

dovecot-sysctl-conf:
  file.managed:
    - name: /etc/sysctl.d/50-dovecot-custom.conf
    - source: salt://lawandorga-mail/dovecot/files/sysctl.conf
    - user: root
    - group: root
    - mode: '0644'

dovecot-sysctl-apply:
  cmd.run:
    - name: sysctl --system
    - onchanges:
      - file: dovecot-sysctl-conf

# -------
# systemd service override
# -------

dovecot-systemd-override-dir:
  file.directory:
    - name: /etc/systemd/system/dovecot.service.d
    - user: root
    - group: root
    - mode: '0755'

dovecot-systemd-override:
  file.managed:
    - name: /etc/systemd/system/dovecot.service.d/override.conf
    - source: salt://lawandorga-mail/dovecot/files/service-override.conf
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: dovecot-systemd-override-dir

dovecot-systemd-daemon-reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: dovecot-systemd-override

# -------
# Firewall
# -------

dovecot-nft:
  file.managed:
    - name: /etc/nftables/custom/ports-dovecot.nft
    - source: salt://lawandorga-mail/dovecot/files/ports-dovecot.nft
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - firewall-nftables-custom-dir
    - watch_in:
      - service: firewall-nftables-service

# -------
# Service
# -------

dovecot-service:
  service.running:
    - name: dovecot.service
    - enable: True
    - require:
      - cmd: dovecot-systemd-daemon-reload
    - watch:
      - file: dovecot-conf
      - file: dovecot-conf-services
      - file: dovecot-conf-tls
      - file: dovecot-conf-auth
      - file: dovecot-conf-logging
      - file: dovecot-conf-mail-storage
      - file: dovecot-conf-mailboxes
      - file: dovecot-conf-lmtp
      - file: dovecot-conf-imap
      - file: dovecot-conf-sql-connection
      - file: dovecot-conf-static-users-passwd
      - file: dovecot-conf-implicit-global-empty
      - file: dovecot-conf-lmtp-mail-plugins
      - file: dovecot-conf-sieve
      - file: dovecot-systemd-override
