/etc/apt/apt.conf.d/00aptproxy:
  file.managed:
    - contents: |
        Acquire {
          Retries "0";
          HTTP {
            Proxy "http://192.168.0.91:3128"; 
          };
        };

# Setup source
/etc/apt/sources.list:
  file.managed:
    - source: salt://openstack/files/sources.list
    - template: jinja

{%- set oscodename=salt['grains.get']('oscodename') %}
{%- if oscodename == "precise" %}
icehouse-source:
    pkgrepo.managed:
      - humanname: Cloudarchive Icehouse
      - name: "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/icehouse main"
      - dist: precise-updates/icehouse
      - file: /etc/apt/sources.list.d/cloudarchive-icehouse.list
      - keyid: EC4926EA
      - keyserver: keyserver.ubuntu.com
      - require_in:
        - cmd: apt-get_update
      - watch_in:
        - cmd: apt-get_update
{%- endif %}

saltstack-salt-{{ oscodename }}:
  pkgrepo.managed:
    - humanname: Saltstack
    - name: "deb http://ppa.launchpad.net/saltstack/salt/ubuntu {{ oscodename }} main"
    - dist: {{ oscodename }}
    - file: /etc/apt/sources.list.d/saltstack-salt-{{ oscodename }}.list
    - keyid: 0E27C0A6
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - cmd: apt-get_update
    - watch_in:
      - cmd: apt-get_update

apt-get_update:
  cmd.wait:
    - name: apt-get update
    - watch:
      - file: /etc/apt/sources.list

salt-master-host:
  host.present:
    - ip: 192.168.1.213
    - name: salt

python-software-properties:
  pkg.installed:
    - refresh: False

salt-minion:
  pkg.installed:
    - refresh: False
  service.running:
    - name: salt-minion
    - restart: True
    - require:
      - host: salt-master-host

