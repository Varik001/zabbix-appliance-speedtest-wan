# Zabbix Speedtest template

This repository contains a Zabbix template and a script to have a fixed speedtest, for appliance, for your Zabbix proxy server.

## Install

Step 1: Install Speedtest itself

In Debian or Ubuntu:

```bash
sudo apt install speedtest-cli
```

In Centos:

```bash
yum -y install epel-release
yum -y install speedtest-cli
```

Test if it work!
```bash
speedtest-cli --simple
```

Step 2: Create some folders for scripts and stuff and make writable:
```bash
sudo mkdir /etc/zabbix/script

sudo mkdir         /run/lock/zabbix-speedtest
sudo chown zabbix: /run/lock/zabbix-speedtest

touch              /var/log/zabbix-speedtest.log
sudo chown zabbix: /var/log/zabbix-speedtest.log
chmod 640          /var/log/zabbix-speedtest.log
```

copy speedtest.sh to Zabbix script folder
```bash
sudo cp ./speedtest.sh /etc/zabbix/script/
```
and make it executable
```bash
sudo chmod +x /etc/zabbix/script/speedtest.sh
```
copy speedtest.conf to zabbix_agentd.conf.d folder
```bash
sudo cp ./speedtest.conf /etc/zabbix/zabbix_agentd.conf.d/
```
copy `speedtest.service` and `speedtest.timer` to `/etc/systemd/system`
```bash
sudo cp speedtest.service speedtest.timer /etc/systemd/system
```
and enable timer:
```bash
sudo systemctl enable --now speedtest.timer
```
Step 3: Import `template_speedtest.xml` to Zabbix server

Step 4: **IMPORTANT** restart Zabbix agent
```bash
sudo service zabbix-agent restart
```

## License

This repository is released under the same terms of Zabbix, GNU General Public License v2.

Copyright (C) 2019, 2020 [Varik001](https://github.com/Varik001)

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
