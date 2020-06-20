{% set sdk_version = "3.0.3" %}
{% set sdk_download_root = "https://github.com/espressif/ESP8266_NONOS_SDK/archive/" %}
{% set sdk_versions = {
  "3.0.3": ["v3.0.3.tar.gz", "76dab14b0858ee8dab76214ac0af02a5e5e666db3989bcfff725be31a2488c3e177bccfc8322bc8ce10854286526139153dcf832b59b6e2d49636034a9e42ee0"],
  "2.2.1": ["v2.2.1.tar.gz", "d46a3871794138ff36fd17cfedb3a07c8cf7194a38ae833b6b086a6470f8753ab445d8b16fa4ffcfd360ef16025f510aab40d0aeee074aec5bace0ad5afd86ca"],
  "2.2.0": ["v2.2.0.tar.gz", "df9fb82f197fd9f761f882d9b9dc76897344b59e0c5f394942bc3bfd730b13a174a11f18cebe86b04deea7c5caf32a7af64b56e9bf96f463fe8168c9455ac12b"],
  "2.1.0": ["v2.1.0.tar.gz", "16b54a15b39730678d7342abc9523d0d0d717c79cefc972d952e44d406b8eee4bf181d82adb0bc9a30eb24caf2101b5cd868f7109044c33065646a44bf905f1a"]} %}

checkout esp-open-sdk:
  git.latest:
    - name: https://github.com/pfalcon/esp-open-sdk
    - rev: master
    - target: {{ pillar['home'] }}/src/esp-open-sdk
    - submodules: True
    - user: vagrant

checkout examples:
  git.latest:
    - name: https://github.com/esp8266/source-code-examples
    - rev: master
    - target: {{ pillar['home'] }}/src/esp-open-sdk-examples
    - submodules: True
    - user: vagrant

{% for version, (archive, hash) in sdk_versions.items() %}
download sdk {{ version }}:
  archive.extracted:
    - name: {{ pillar['home'] }}/src
    - source: {{ sdk_download_root }}{{ archive }}
    - source_hash: {{ hash }}
    - user: vagrant
{% endfor %}

checkout mqtt:
  git.latest:
    - name: https://github.com/tuanpmt/esp_mqtt/
    - rev: master
    - target: {{ pillar['home'] }}/src/esp_mqtt
    - user: vagrant

patch crosstools-ng for bash 5:
  file.patch:
    - name: {{ pillar['home'] }}/src/esp-open-sdk/crosstool-NG/configure.ac
    - source: /vagrant/saltstack/srv/salt/files/crosstool-ng-bash5.patch
    - hash: 6cc1d10b261527f41c6f023fc09443fc3af9986cb30420c19385aa0adce34b93
    - strip: 1

bootstrap:
  cmd.run:
    - cwd: {{ pillar['home'] }}/src/esp-open-sdk/crosstool-NG
    - runas: vagrant
    - name: |
        ./bootstrap

build esp-open-sdk:
  cmd.run:
    - cwd: {{ pillar['home'] }}/src/esp-open-sdk/
    - runas: vagrant
    - name: |
        make STANDALONE=n

esptool:
  pip.installed:
    - user: vagrant
    - pkgs:
      - esptool
      - pyserial

download nim esp8266 sdk:
  archive.extracted:
    - name: {{ pillar['home'] }}/src
    - source: https://github.com/clj/nim-esp8266-sdk/releases/download/release-20200612/nim_esp8266_nonos_sdk-20200612.zip
    - source_hash: 051dbdb9215194905b198067c610009dde2b65c133f3b71ca4a7f0fd9d1f39456aa5d910089ec81a6f8c00df8986a755d257c006394af84fcc050cb8c82a2f04
    - user: vagrant

{{ pillar['home'] }}/src/nim-esp8266-examples:
  file.directory:
    - user: vagrant
    - group: vagrant
    - mode: 755
    - makedirs: True

download nim esp8266 examples:
  archive.extracted:
    - name: {{ pillar['home'] }}/src/nim-esp8266-examples
    - source: https://github.com/clj/nim-esp8266-examples/archive/release-20200612.tar.gz
    - options: --strip-components=1
    - enforce_toplevel: false
    - source_hash: e3e824223fc0f6de01fc6eba890c5f7679db10807f76ca9b748910d9024fc6129e32506f61f32a852664eac9e2e2695bb2cba0e22a8070466d463bca5fb44df9
    - user: vagrant

{{ pillar['home'] }}/.bashrc:
  file.append:
    - text:
      - export PATH="$HOME/src/esp-open-sdk/xtensa-lx106-elf/bin/:$PATH"
      - export PATH="$HOME/.local/bin/:$PATH"  # prefer pip installed esptool
      - export XTENSA_TOOLS_ROOT="$HOME/src/esp-open-sdk/xtensa-lx106-elf/bin/"
      - export SDK_BASE="$HOME/src/ESP8266_NONOS_SDK-{{ sdk_version }}/"
      - export NIM_SDK_BASE="$HOME/src/nim-esp8266-sdk/{{ sdk_version }}/"
