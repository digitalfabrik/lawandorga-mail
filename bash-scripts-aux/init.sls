# Auxiliary Bash script library installation.
# Corresponds to Ansible role: bash-scripts-aux

bash-scripts-aux-dir:
  file.directory:
    - name: /usr/local/lib/bash
    - user: root
    - group: root
    - mode: '0755'

bash-scripts-aux-basic:
  file.managed:
    - name: /usr/local/lib/bash/basic.bash
    - source: salt://lawandorga-mail/bash-scripts-aux/files/basic.bash
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: bash-scripts-aux-dir
