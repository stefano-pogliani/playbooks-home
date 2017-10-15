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

  * `authgateway.yml`
