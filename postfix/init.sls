# lawandorga-mail/postfix
# Installs and configures the Postfix MTA.
# Mail filtering (DKIM/SPF/DMARC/spam) is handled by Rspamd via a milter;
# see ../rspamd.  Corresponds to Ansible roles: mail/postfix

{% set m = pillar['lawandorga_mail'] %}

# main.cf references the DH parameter file (smtpd_tls_dh1024_param_file), so it
# must exist before Postfix starts.
include:
  - lawandorga-mail.tls-dhparams

# -------
# Packages
# -------

postfix-packages:
  pkg.installed:
    - pkgs:
      - postfix
      - postfix-doc
      - postfix-pgsql

# -------
# Users / Groups
# -------

postfix-group-vmail:
  group.present:
    - name: vmail
    - gid: 525
    - system: True

# -------
# Directories
# -------

postfix-maps-dir:
  file.directory:
    - name: /etc/postfix/maps
    - user: root
    - group: root
    - mode: '0755'

postfix-sets-dir:
  file.directory:
    - name: /etc/postfix/sets
    - user: root
    - group: root
    - mode: '0755'

postfix-header-checks-dir:
  file.directory:
    - name: /etc/postfix/header-checks
    - user: root
    - group: root
    - mode: '0755'

# -------
# Postfix config files
# -------

postfix-main-cf:
  file.managed:
    - name: /etc/postfix/main.cf
    - source: salt://lawandorga-mail/postfix/files/main.cf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: postfix-packages

postfix-master-cf:
  file.managed:
    - name: /etc/postfix/master.cf
    - source: salt://lawandorga-mail/postfix/files/master.cf
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: postfix-packages

# -------
# Header checks
# -------

postfix-header-checks-privacy:
  file.managed:
    - name: /etc/postfix/header-checks/privacy.re
    - source: salt://lawandorga-mail/postfix/files/header-checks/privacy.re
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: postfix-header-checks-dir

# -------
# Maps
# -------

postfix-maps-static-aliases:
  file.managed:
    - name: /etc/postfix/maps/static-aliases
    - source: salt://lawandorga-mail/postfix/files/maps/static-aliases.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: postfix-maps-dir

postfix-maps-static-aliases-postmap:
  cmd.run:
    - name: postmap /etc/postfix/maps/static-aliases
    - require:
      - file: postfix-maps-static-aliases
    - onchanges:
      - file: postfix-maps-static-aliases

postfix-maps-id-static-users:
  file.managed:
    - name: /etc/postfix/maps/id_static-users
    - source: salt://lawandorga-mail/postfix/files/maps/id_static-users.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: postfix-maps-dir

postfix-maps-id-static-users-postmap:
  cmd.run:
    - name: postmap /etc/postfix/maps/id_static-users
    - require:
      - file: postfix-maps-id-static-users
    - onchanges:
      - file: postfix-maps-id-static-users

postfix-maps-aliases-pgsql:
  file.managed:
    - name: /etc/postfix/maps/aliases.pgsql.cf
    - source: salt://lawandorga-mail/postfix/files/maps/aliases.pgsql.cf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: postfix
    - mode: '0640'
    # Keep the database password out of the state output.
    - show_changes: False
    - require:
      - file: postfix-maps-dir
      - pkg: postfix-packages

postfix-maps-postmaster-aliases-pgsql:
  file.managed:
    - name: /etc/postfix/maps/postmaster-aliases.pgsql.cf
    - source: salt://lawandorga-mail/postfix/files/maps/postmaster-aliases.pgsql.cf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: postfix
    - mode: '0640'
    # Keep the database password out of the state output.
    - show_changes: False
    - require:
      - file: postfix-maps-dir
      - pkg: postfix-packages

postfix-maps-sender-to-login-pgsql:
  file.managed:
    - name: /etc/postfix/maps/sender-to-login.pgsql.cf
    - source: salt://lawandorga-mail/postfix/files/maps/sender-to-login.pgsql.cf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: postfix
    - mode: '0640'
    # Keep the database password out of the state output.
    - show_changes: False
    - require:
      - file: postfix-maps-dir
      - pkg: postfix-packages

# -------
# Sets
# -------

postfix-sets-mailbox-domains-pgsql:
  file.managed:
    - name: /etc/postfix/sets/mailbox-domains.pgsql.cf
    - source: salt://lawandorga-mail/postfix/files/sets/mailbox-domains.pgsql.cf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: postfix
    - mode: '0640'
    # Keep the database password out of the state output.
    - show_changes: False
    - require:
      - file: postfix-sets-dir
      - pkg: postfix-packages

postfix-sets-users-pgsql:
  file.managed:
    - name: /etc/postfix/sets/users.pgsql.cf
    - source: salt://lawandorga-mail/postfix/files/sets/users.pgsql.cf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: postfix
    - mode: '0640'
    # Keep the database password out of the state output.
    - show_changes: False
    - require:
      - file: postfix-sets-dir
      - pkg: postfix-packages

# -------
# Firewall
# -------

postfix-nft:
  file.managed:
    - name: /etc/nftables/custom/ports-postfix.nft
    - source: salt://lawandorga-mail/postfix/files/ports-postfix.nft
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - firewall-nftables-custom-dir
    - watch_in:
      - service: firewall-nftables-service

# -------
# Services
# -------

postfix-service:
  service.running:
    - name: postfix.service
    - enable: True
    - require:
      - cmd: tls-dhparams-initial
    - watch:
      - file: postfix-main-cf
      - file: postfix-master-cf
      - file: postfix-header-checks-privacy
      - file: postfix-maps-static-aliases
      - file: postfix-maps-aliases-pgsql
      - file: postfix-maps-postmaster-aliases-pgsql
      - file: postfix-maps-sender-to-login-pgsql
      - file: postfix-sets-mailbox-domains-pgsql
      - file: postfix-sets-users-pgsql
