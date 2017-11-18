Ansible Playbooks for a Home Network
====================================
TODO


Usage
-----
```bash
# Install galaxy roles.
ansible-galaxy install --roles-path ./roles -r requirements.yml

# Call ansible directly.
ansible PATTERN -a 'COMMAND'
ansible PATTERN -m MODULE
ansible PATTERN --ask-become-pass --become ...

# Call ansible playbook.
ansible-playbook playbooks/some/playbook.yml
ansible-playbook --ask-become-pass \
  --vault-id authgateway@.authgateway.vaultsecret \
  ... \
  playbooks/infra/monitoring.yml

# Clean up Ansible retry files.
find . -name '*.retry' -print -delete
```


Secrets
-------
Secrets are stored in Ansible Vaults.
The master password was generated as below and is git ignored.

The following is a list of vaults:

  * `authgateway`: secrets used to configure AuthGateway.
  * `grafana`: secrets used to configure Grafana.

```bash
openssl rand -base64 4096 | tr -d '\n' > .authgateway.vaultsecret
openssl rand -base64 4096 | tr -d '\n' > .backups.vaultsecret
openssl rand -base64 4096 | tr -d '\n' > .email.vaultsecret
openssl rand -base64 4096 | tr -d '\n' > .grafana.vaultsecret
openssl rand -base64 4096 | tr -d '\n' > .me.vaultsecret

# Generate random secrets.
openssl rand -base64 48

# oauth2_proxy has requirements on secets size.
openssl rand -base64 32
```


Testing
-------
Testing is performed using kitchen and docker.
A single kitchen setup is available at the root and various
configurations can be tweaked to test specific things.

```bash
bundle install --path=.vendor --binstubs
./bin/kitchen test
```

### OS Upgrades
Prior to upgading the OS on the server test that all tasks and
playbooks work with the new target OS.

### Tasks

  * `runtime/nodejs.yml`

### Playbooks

  * `infra/authgateway.yml`
  * `infra/backup.yml`
  * `infra/email.yml`
  * `infra/monitoring.yml`
