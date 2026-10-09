# lawandorga-mail/delete-old-userdata
# Installs the script that deletes mail data for accounts no longer in the DB.
# Corresponds to Ansible role: mail/delete-old-userdata

{% set m = pillar['lawandorga_mail'] %}

# -------
# Packages
# -------

delete-old-userdata-packages:
  pkg.installed:
    - pkgs:
      - postgresql-client

# -------
# Script directory
# -------

delete-old-userdata-script-dir:
  file.directory:
    - name: /usr/local/lib/mail-delete-old-userdata
    - user: root
    - group: root
    - mode: '0755'

# -------
# Script (contains SQL password — restrict access)
# -------

delete-old-userdata-script:
  file.managed:
    - name: /usr/local/lib/mail-delete-old-userdata/delete-old-userdata.bash
    - source: salt://lawandorga-mail/delete-old-userdata/files/delete-old-userdata.bash.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: {{ m['mail_dovecot_storage_user'] }}
    - group: {{ m['mail_dovecot_storage_group'] }}
    - mode: '0500'
    # Keep the database password out of the state output.
    - show_changes: False
    - require:
      - file: delete-old-userdata-script-dir
      - pkg: delete-old-userdata-packages

# -------
# Crontab
# -------

delete-old-userdata-crontab:
  file.managed:
    - name: /etc/cron.d/mail-delete-old-userdata
    - source: salt://lawandorga-mail/delete-old-userdata/files/crontab.j2
    - template: jinja
    - context:
        m: {{ m | tojson }}
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: delete-old-userdata-script
