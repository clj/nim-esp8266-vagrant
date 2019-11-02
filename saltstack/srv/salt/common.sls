common packages:
  pkg:
    - installed
    - pkgs:
      - htop
      - jq
      - screen
      - usbutils
      - vim
      - xz-utils

vagrant:
  user.present:
    - groups:
      - dialout
    - remove_groups: False

{{ pillar['home'] }}/src:
  file.directory:
    - user: vagrant
    - group: vagrant
    - mode: 755
    - makedirs: True
