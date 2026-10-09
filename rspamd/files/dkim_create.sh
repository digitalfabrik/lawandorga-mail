#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Helper to generate a fresh DKIM key + DNS record for rotation.
#  - The selector must match `mail_dkim_selector` in the pillar.
#  - After running, publish the contents of signing.txt as the DNS TXT record
#    and store signing.key in Passbolt (mail_dkim_key_uuid) as the base64 body
#    only, without the `-----BEGIN/END ...-----' marker lines.
SELECTOR="${1:-2022-12.law-orga}"

mkdir -p /var/lib/rspamd/dkim/
rspamadm dkim_keygen -b 2048 -s "$SELECTOR" -k /var/lib/rspamd/dkim/signing.key > /var/lib/rspamd/dkim/signing.txt
chown -R _rspamd:_rspamd /var/lib/rspamd/dkim
chmod 440 /var/lib/rspamd/dkim/*
