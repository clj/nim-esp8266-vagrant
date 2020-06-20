{% set path_env = salt['environ.get']('PATH', '/bin:/usr/bin') %}

download choosenim init:
  file.managed:
    - name: /tmp/choosenim-init.sh
    - source: https://nim-lang.org/choosenim/init.sh
    - source_hash: sha512=44aec0df4bc7c601b779e9701417f19b54af0f0bc53c9b9b0bad8d88f9ae9d46c2a219bbdf3d5daee8969ce6e3e404b38889386a12d628bfe7e0ab190d482416
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
