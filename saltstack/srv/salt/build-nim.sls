{% set path_env = salt['environ.get']('PATH', '/bin:/usr/bin') %}

download choosenim init:
  file.managed:
    - name: /tmp/choosenim-init.sh
    - source: https://nim-lang.org/choosenim/init.sh
    - source_hash: sha512=3e953275a719355ecdee948bfcfed4116510d084c9bb5937610e201d8b307757d0e5bafe620d840399146b0ea369cb88faa2e40bf0b50ff324e7056f68df0afe
    - user: vagrant
    - group: vagrant

install choosenim:
  cmd.run:
    - cwd: /tmp/
    - runas: vagrant
    - name: sh /tmp/choosenim-init.sh -y
    - creates: $HOME/.nimble/bin/choosenim

install nim stable:
  cmd.run:
    - runas: vagrant
    - name: $HOME/.nimble/bin/choosenim stable

{% set nimble_path = [pillar['home'] + '/.nimble/bin', path_env] | join(':') %}

# See: https://github.com/nim-lang/c2nim/issues/115

install compiler package:
  cmd.run:
    - runas: vagrant
    - name: $HOME/.nimble/bin/nimble install compiler@#head --accept --noColor
    - env:
      - PATH: {{ nimble_path }}

install c2nim package:
  cmd.run:
    - runas: vagrant
    - name: $HOME/.nimble/bin/nimble install c2nim@#head --accept --noColor
    - env:
      - PATH: {{ nimble_path }}

add nim paths to /home/vagrant/.bashrc:
  file.append:
    - name: {{ pillar['home'] }}/.bashrc
    - text:
      - export PATH="$HOME/.nimble/bin:$PATH"
