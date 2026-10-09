# lawandorga-mail/tls-dhparams
# Generates DH parameters for TLS; daily cron job.
# Corresponds to Ansible role: tls/dhparams

{% set m = pillar['lawandorga_mail'] %}

# The update script sources the auxiliary Bash library; without it the script
# aborts before generating anything.
include:
  - lawandorga-mail.bash-scripts-aux

# -------
# Directories
# -------

tls-dhparams-script-dir:
  file.directory:
    - name: /usr/local/lib/tls-dhparams
    - user: root
    - group: root
    - mode: '0755'

tls-dhparams-data-dir:
  file.directory:
    - name: /var/local/tls-dhparams
    - user: root
    - group: root
    - mode: '0755'

# -------
# DH params update script
# -------

tls-dhparams-update-script:
  file.managed:
    - name: /usr/local/lib/tls-dhparams/update.bash
    - source: salt://lawandorga-mail/tls-dhparams/files/update.bash.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: tls-dhparams-script-dir
      - file: bash-scripts-aux-basic

# -------
# Initial generation
# -------
# The cron job below only runs once a day, so on a fresh host the parameter
# file would be missing until then and Postfix would fall back to its
# compiled-in defaults.  Generate it once, synchronously, if it is absent.
# Note: `openssl dhparam 4096` is slow (minutes); it only runs on first apply.

tls-dhparams-initial:
  cmd.run:
    - name: /usr/local/lib/tls-dhparams/update.bash
    - creates: {{ m['tls_dhparams_path'] }}
    - require:
      - file: tls-dhparams-update-script
      - file: tls-dhparams-data-dir

# -------
# Crontab (daily at 04:07)
# -------

tls-dhparams-crontab:
  file.managed:
    - name: /etc/cron.d/tls-dhparams
    - source: salt://lawandorga-mail/tls-dhparams/files/crontab.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: tls-dhparams-update-script
