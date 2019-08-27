Required:

Step 1: Install Speedtest itself

~$ sudo apt-get install speedtest-cli

Test if it work!

~$ speedtest --simple

Step 2: Create folder for scripts and copy files.

~$ sudo mkdir /etc/zabbix/script

and change premissions to 777
~$ sudo chmod 777 /etc/zabbix/script

copy speedtest.sh to zabbix script folder
~$ sudo cp ./speedtest.sh /etc/zabbix/script/

and make it executable
~$ sudo chmod +x /etc/zabbix/script/speedtest.sh

copy speedtest.conf to zabbix_agentd.d folder
~$ sudo cp ./speedtest.conf /etc/zabbix/zabbix_agentd.d/

copy speedtest.service and speedtest.timer to /etc/systemd/system
~$ cp speedtest.service speedtest.timer /etc/systemd/system

and enable timer:
~$ systemctl enable --now speedtest.time

Step 3: Import template_speedtest.xml to Zabbix server

Step 4: INPORTANT restart zabbix agent

~$ sudo service zabbix-agent restart