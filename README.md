thanks to https://medium.com/caendra-tech/monitoring-system-updates-with-zabbix-7a888510a457

Checking updates for on CentOs

zabbix installation

##
add repo:

rpm -Uvh https://repo.zabbix.com/zabbix/6.0/rhel/7/x86_64/zabbix-release-6.0-2.el7.noarch.rpm

##
install:

yum install zabbix-agent zabbix-sender

##
edit conf file

vi /etc/zabbix/zabbix_agentd.conf

##
add line to .conf, under User-defined parameters

UserParameter=os.updates.pending,cat "/run/zabbix/zabbix.count.updates"

##
create folder /opt/zabbix_scripts

##
install wget

yum install wget

##
download script to created folder 

wget https://github.com/510r/Zabbix-update-checks/raw/main/check_updates.sh

##
create a script to run daily

cat /etc/cron.daily/zabbix_check_pending_updates

#!/bin/sh
bash "/opt/zabbix_scripts/check_updates.sh"

mark it as executable

chmod +x /etc/cron.daily/zabbix_check_pending_updates

##
check the script working

sh /opt/zabbix_scripts/check_updates.sh
zabbix_agentd -p | grep os.updates.pending   

##
reconfig selinux if needed

##
reload zabbix agent

systemctl restart zabbix-agent

##
zabbix not connecting

systemctl stop firewalld.service

##
import simple template
