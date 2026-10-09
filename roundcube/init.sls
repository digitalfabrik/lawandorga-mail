# lawandorga-mail/roundcube
# Installs and configures Roundcube webmail.
# Corresponds to Ansible role: web/app/mail

{% set m = pillar['lawandorga_mail'] %}

# -------
# Packages
# -------

# Install php-fpm first (before roundcube) to avoid pulling in
# libapache2-mod-php as a dependency of roundcube-core.
roundcube-php-fpm:
  pkg.installed:
    - name: php-fpm

# Install roundcube and spelling packages together to avoid pulling in
# unwanted default dependencies (e.g. roundcube-mysql, a default pspell
# backend).
roundcube-packages:
  pkg.installed:
    - pkgs:
      - roundcube
      - roundcube-pgsql
      - roundcube-plugins-extra
      - roundcube-skin-larry
      - php-enchant
      - postgresql-client
{%- for backend in m['web_app_mail_spelling_backends'] %}
      - {{ backend['package'] }}
{%- endfor %}
    - require:
      - pkg: roundcube-php-fpm

# -------
# Script directory
# -------

roundcube-script-dir:
  file.directory:
    - name: /usr/local/lib/webmail
    - user: root
    - group: root
    - mode: '0755'

# -------
# Roundcube configuration
# -------

roundcube-config:
  file.managed:
    - name: /etc/roundcube/config.inc.php
    - source: salt://lawandorga-mail/roundcube/files/roundcube.conf.php.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: www-data
    - group: www-data
    - mode: '0400'
    # Keep the database password out of the state output.
    - show_changes: False
    - require:
      - pkg: roundcube-packages

# -------
# Random des_key (generated once)
# -------

# Generate the des_key file once; never overwrite it.
roundcube-key-generate:
  cmd.run:
    - name: >
        umask 077;
        printf "<?php\n\$config['des_key'] = '%s';\n"
        "$(head -c 18 /dev/urandom | base64)"
        > '/etc/roundcube/key.conf.php'
    - creates: /etc/roundcube/key.conf.php
    - require:
      - pkg: roundcube-packages

roundcube-key-permissions:
  file.managed:
    - name: /etc/roundcube/key.conf.php
    - user: www-data
    - group: www-data
    - mode: '0400'
    - replace: False
    - require:
      - cmd: roundcube-key-generate

# -------
# About page
# -------

roundcube-about:
  file.managed:
    - name: /etc/roundcube/about.html
    - source: salt://lawandorga-mail/roundcube/files/about.html.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: roundcube-packages

# -------
# dovecot_impersonate plugin config
# (plugin itself is in roundcube-plugins-extra package)
# -------

roundcube-plugin-dovecot-impersonate-config:
  file.managed:
    - name: /etc/roundcube/plugins/dovecot_impersonate/config.inc.php
    - source: salt://lawandorga-mail/roundcube/files/plugins/dovecot_impersonate/config.inc.php.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: roundcube-packages

# -------
# dovecot_impersonate_smtp custom plugin
# -------

roundcube-custom-plugins-base-dir:
  file.directory:
    - name: /usr/local/share/roundcube
    - user: root
    - group: root
    - mode: '0755'

roundcube-custom-plugins-dir:
  file.directory:
    - name: /usr/local/share/roundcube/plugins
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: roundcube-custom-plugins-base-dir

roundcube-plugin-dovecot-impersonate-smtp-dir:
  file.directory:
    - name: /usr/local/share/roundcube/plugins/dovecot_impersonate_smtp
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: roundcube-custom-plugins-dir

roundcube-plugin-dovecot-impersonate-smtp-php:
  file.managed:
    - name: /usr/local/share/roundcube/plugins/dovecot_impersonate_smtp/dovecot_impersonate_smtp.php
    - source: salt://lawandorga-mail/roundcube/files/plugins/dovecot_impersonate_smtp/dovecot_impersonate_smtp.php
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: roundcube-plugin-dovecot-impersonate-smtp-dir

roundcube-plugin-dovecot-impersonate-smtp-composer:
  file.managed:
    - name: /usr/local/share/roundcube/plugins/dovecot_impersonate_smtp/composer.json
    - source: salt://lawandorga-mail/roundcube/files/plugins/dovecot_impersonate_smtp/composer.json
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: roundcube-plugin-dovecot-impersonate-smtp-dir

roundcube-plugin-dovecot-impersonate-smtp-link:
  file.symlink:
    - name: /var/lib/roundcube/plugins/dovecot_impersonate_smtp
    - target: /usr/local/share/roundcube/plugins/dovecot_impersonate_smtp
    - require:
      - file: roundcube-plugin-dovecot-impersonate-smtp-php
      - file: roundcube-plugin-dovecot-impersonate-smtp-composer
      - pkg: roundcube-packages

# -------
# login_page_extra_links custom plugin
# -------

roundcube-plugin-login-page-extra-links-dir:
  file.directory:
    - name: /usr/local/share/roundcube/plugins/login_page_extra_links
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: roundcube-custom-plugins-dir

roundcube-plugin-login-page-extra-links-php:
  file.managed:
    - name: /usr/local/share/roundcube/plugins/login_page_extra_links/login_page_extra_links.php
    - source: salt://lawandorga-mail/roundcube/files/plugins/login_page_extra_links/login_page_extra_links.php
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: roundcube-plugin-login-page-extra-links-dir

roundcube-plugin-login-page-extra-links-composer:
  file.managed:
    - name: /usr/local/share/roundcube/plugins/login_page_extra_links/composer.json
    - source: salt://lawandorga-mail/roundcube/files/plugins/login_page_extra_links/composer.json
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: roundcube-plugin-login-page-extra-links-dir

roundcube-plugin-login-page-extra-links-link:
  file.symlink:
    - name: /var/lib/roundcube/plugins/login_page_extra_links
    - target: /usr/local/share/roundcube/plugins/login_page_extra_links
    - require:
      - file: roundcube-plugin-login-page-extra-links-php
      - file: roundcube-plugin-login-page-extra-links-composer
      - pkg: roundcube-packages

# login_page_extra_links: config in /usr/local/etc/roundcube/plugins/
roundcube-plugin-login-page-extra-links-confbase-dir:
  file.directory:
    - name: /usr/local/etc/roundcube
    - user: root
    - group: root
    - mode: '0755'

roundcube-plugin-login-page-extra-links-confplugins-dir:
  file.directory:
    - name: /usr/local/etc/roundcube/plugins
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: roundcube-plugin-login-page-extra-links-confbase-dir

roundcube-plugin-login-page-extra-links-conf-dir:
  file.directory:
    - name: /usr/local/etc/roundcube/plugins/login_page_extra_links
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: roundcube-plugin-login-page-extra-links-confplugins-dir

roundcube-plugin-login-page-extra-links-conf:
  file.managed:
    - name: /usr/local/etc/roundcube/plugins/login_page_extra_links/config.inc.php
    - source: salt://lawandorga-mail/roundcube/files/plugins/login_page_extra_links/config.inc.php.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: roundcube-plugin-login-page-extra-links-conf-dir

roundcube-plugin-login-page-extra-links-conf-link:
  file.symlink:
    - name: /usr/local/share/roundcube/plugins/login_page_extra_links/config.inc.php
    - target: /usr/local/etc/roundcube/plugins/login_page_extra_links/config.inc.php
    - require:
      - file: roundcube-plugin-login-page-extra-links-conf
      - file: roundcube-plugin-login-page-extra-links-dir

# -------
# tmpfiles.d: upload tmp dir
# -------

roundcube-upload-tmpdir-tmpfiles:
  file.managed:
    - name: /etc/tmpfiles.d/php-upload-tmpdir.conf
    - source: salt://lawandorga-mail/roundcube/files/upload-tmpdir.tmpfiles.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'

roundcube-upload-tmpdir-create:
  cmd.run:
    - name: systemd-tmpfiles --create /etc/tmpfiles.d/php-upload-tmpdir.conf
    - onchanges:
      - file: roundcube-upload-tmpdir-tmpfiles

# -------
# PHP-FPM configuration
# -------

# Configure php-fpm to log to syslog.
roundcube-php-fpm-log-syslog:
  file.replace:
    - name: /etc/php/{{ m['web_app_mail_php_version'] }}/fpm/php-fpm.conf
    - pattern: '^;?error_log *=.*'
    - repl: 'error_log = syslog'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

# php.ini settings — one file.replace per setting (matches Ansible lineinfile).
# Notes:
#  * Settings with an [importantly] good default not explicitly set.
#  * On upgrades, check for changed defaults.
#  * Originally written for PHP 7.4; reviewed for 8.2.
#  * References:
#      [0] https://www.php.net/security-note.php
#      [1] /usr/share/doc/php<VERSION>-fpm/README.Debian.security
#      [4] https://www.php.net/manual/en/session.security.ini.php
{% set _php_ini = '/etc/php/' + m['web_app_mail_php_version'] + '/fpm/php.ini' %}
{% set _attach_limit = (m['mail_postfix_message_size_limit'] | int / 2) | int %}
{% set _attach_limit_margin = _attach_limit + 1048576 %}

# Notes:
#  * This should not be relied upon too much.  [0, 1]
#  * `/var/log/roundcube` should not be actually used (but rather the
#    syslog), but PHP complains anyways, if it is not included in
#    `open_basedir`.
#  * Partially determined by trial and error.
roundcube-php-ini-open-basedir:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?open_basedir *=.*'
    - repl: 'open_basedir = "/usr/share/php:/usr/lib/php:/var/lib/php:/tmp/php-upload:/usr/share/javascript:/usr/share/nodejs:/usr/share/roundcube:/usr/local/share/roundcube:/var/lib/roundcube:/etc/roundcube:/usr/local/etc/roundcube:/var/log/roundcube"'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

# The default is due to / for Apache.
roundcube-php-ini-cgi-rfc2616-headers:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?cgi\.rfc2616_headers *=.*'
    - repl: 'cgi.rfc2616_headers = 1'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-upload-tmp-dir:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?upload_tmp_dir *=.*'
    - repl: 'upload_tmp_dir = /tmp/php-upload'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-upload-max-filesize:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?upload_max_filesize *=.*'
    - repl: 'upload_max_filesize = {{ _attach_limit }}'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

# See also nginx client_max_body_size.
roundcube-php-ini-post-max-size:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?post_max_size *=.*'
    - repl: 'post_max_size = {{ _attach_limit_margin }}'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-max-execution-time:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?max_execution_time *=.*'
    - repl: 'max_execution_time = 120'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-date-timezone:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?date\.timezone *=.*'
    - repl: 'date.timezone = {{ m['timezone'] }}'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

# Session security [4]:

roundcube-php-ini-session-save-path:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?session\.save_path *=.*'
    - repl: 'session.save_path = "/var/lib/php/sessions"'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-session-use-strict-mode:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?session\.use_strict_mode *=.*'
    - repl: 'session.use_strict_mode = True'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-session-cookie-secure:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?session\.cookie_secure *=.*'
    - repl: 'session.cookie_secure = True'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-session-cookie-httponly:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?session\.cookie_httponly *=.*'
    - repl: 'session.cookie_httponly = True'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-session-cookie-samesite:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?session\.cookie_samesite *=.*'
    - repl: 'session.cookie_samesite = Strict'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-session-gc-probability:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?session\.gc_probability *=.*'
    - repl: 'session.gc_probability = 1'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-session-gc-divisor:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?session\.gc_divisor *=.*'
    - repl: 'session.gc_divisor = 100'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-session-sid-length:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?session\.sid_length *=.*'
    - repl: 'session.sid_length = 64'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

roundcube-php-ini-session-sid-bits-per-character:
  file.replace:
    - name: {{ _php_ini }}
    - pattern: '^;?session\.sid_bits_per_character *=.*'
    - repl: 'session.sid_bits_per_character = 6'
    - require:
      - pkg: roundcube-php-fpm
    - watch_in:
      - service: roundcube-php-fpm-service

# -------
# Database initialization
# -------

# The password is passed through `env`, not interpolated into the commands:
# Salt echoes state `name`/`unless` values into the state return, job cache and
# event bus, and a `'` in the password would break out of the shell quoting.
# `env` is applied to `unless` as well (POSSIBLE_CMD_ARGS in salt/state.py).
roundcube-db-init:
  cmd.run:
    - env:
        PGPASSWORD: {{ pillar['passbolt'][m['database_password_uuid']] | tojson }}
        PGSSLMODE: require
    - name: >
        psql
        --host='{{ m['database_server_address'] }}'
        --port='{{ m['database_server_port'] }}'
        --dbname='{{ m['database_name_webmail'] }}'
        --username='{{ m['database_user'] }}'
        --no-password
        --no-psqlrc
        --no-readline
        --set=ON_ERROR_STOP=on
        --echo-errors
        --quiet
        --single-transaction
        --file=/usr/share/dbconfig-common/data/roundcube/install/pgsql
    - unless: >
        psql
        --host='{{ m['database_server_address'] }}'
        --port='{{ m['database_server_port'] }}'
        --dbname='{{ m['database_name_webmail'] }}'
        --username='{{ m['database_user'] }}'
        --no-password
        --no-psqlrc
        --no-readline
        --quiet
        --tuples-only
        --no-align
        --command='\dt'
        | grep -q .
    - require:
      - pkg: roundcube-packages

# -------
# Webmail delete-old-userdata
# -------

roundcube-delete-old-userdata-script:
  file.managed:
    - name: /usr/local/lib/webmail/delete-old-userdata.bash
    - source: salt://lawandorga-mail/roundcube/files/delete-old-userdata.bash.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: www-data
    - group: www-data
    - mode: '0500'
    # Keep the database password out of the state output.
    - show_changes: False
    - require:
      - file: roundcube-script-dir
      - pkg: roundcube-packages

roundcube-delete-old-userdata-crontab:
  file.managed:
    - name: /etc/cron.d/webmail-delete-old-userdata
    - source: salt://lawandorga-mail/roundcube/files/delete-old-userdata.crontab.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: roundcube-delete-old-userdata-script

# -------
# Nginx configuration
# -------

# This file is a server-block *fragment* (add_header/root/location …), not a
# standalone config.  The generic `nginx` state's per-domain server block
# (`002-<domainset>.conf`) includes `/etc/nginx/conf-available/<domainset>.conf`
# inside its `server { }`, so we install the fragment there.  The domainset key
# is $letsencrypt_domainset, which is not necessarily the fqdn (see
# pillars/letsencrypt/.../mail-laworga.sls).
roundcube-nginx-conf:
  file.managed:
    - name: /etc/nginx/conf-available/{{ m['letsencrypt_domainset'] }}.conf
    - source: salt://lawandorga-mail/roundcube/files/nginx-roundcube.server.conf.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - watch_in:
      - service: nginx-service

# Remove the old location: the fragment used to be dropped into conf.d, where
# nginx auto-includes it at `http` scope, making its `location` directives
# illegal ("location directive is not allowed here").
roundcube-nginx-conf-legacy-absent:
  file.absent:
    - name: /etc/nginx/conf.d/roundcube.server.conf
    - watch_in:
      - service: nginx-service

# -------
# Roundcube cron MAILTO fix
# -------

# The roundcube-core package installs /etc/cron.d/roundcube-core without a
# MAILTO line; ensure cron sends output to root.
roundcube-cron-mailto:
  file.replace:
    - name: /etc/cron.d/roundcube-core
    - pattern: '^MAILTO *=.*'
    - repl: 'MAILTO=root'
    - prepend_if_not_found: True
    - require:
      - pkg: roundcube-packages

# -------
# Services
# -------

roundcube-php-fpm-service:
  service.running:
    - name: php{{ m['web_app_mail_php_version'] }}-fpm.service
    - enable: True
    - require:
      - pkg: roundcube-php-fpm
