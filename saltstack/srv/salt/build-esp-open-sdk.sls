{% set sdk_version = "2.2.1" %}
{% set sdk_download_root = "https://github.com/espressif/ESP8266_NONOS_SDK/archive/" %}
{% set sdk_versions = {
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
    - source: https://github.com/clj/nim-esp8266-sdk/releases/download/release-20191030/nim_esp8266_nonos_sdk-20191030.tar.gz
    - source_hash: ac9106ae6af713ad2e04174459161628fd628db18dee10bc93b05a746ef1fabdad773d10e4e5108f16cf27c2e91a39d9385534ebd57fd6af2d6bbcef659b47c9
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
    - source: https://github.com/clj/nim-esp8266-examples/archive/release-20191031.tar.gz
    - options: --strip-components=1
    - enforce_toplevel: false
    - source_hash: 1899617f48e67fefcb97a4b752ba2c9ffa9258b62046e231fdc35c3a68c9c1fdaf2424b2178fba92562f4a8d6ecb971caeab13d78193ed3ddc76ddab4c71be24
    - user: vagrant

{{ pillar['home'] }}/.bashrc:
  file.append:
    - text:
      - export PATH="$HOME/src/esp-open-sdk/xtensa-lx106-elf/bin/:$PATH"
      - export PATH="$HOME/.local/bin/:$PATH"  # prefer pip installed esptool
      - export XTENSA_TOOLS_ROOT="$HOME/src/esp-open-sdk/xtensa-lx106-elf/bin"
      - export SDK_BASE="$HOME/src/ESP8266_NONOS_SDK-{{ sdk_version }}/"
      - export NIM_SDK_BASE="$HOME/src/nim-esp8266-sdk/{{ sdk_version }}/"
