#!/bin/bash
#Arthor:		Kylin
#Loaction:		Guangzhou
#Date:			2015年7月30日
#Modify date:	2015/12/1
#Usage:			一键安装collectd+influxdb+grafana性能监控系统

. /etc/rc.d/init.d/functions


INFLUXDB=influxdb-0.8.8-1.x86_64.rpm
EPEL_NAME=epel-release-7-5.noarch.rpm
GRAFANA=grafana-2.0.2-1.x86_64.rpm

COLLECTD_CONF=/etc/collectd.conf
INFLUXDC_CONF=/opt/influxdb/shared/config.toml


function Prepare_Envrionment {
	echo "Setting timezone"
	timedatectl set-timezone Asia/Shanghai
	/usr/sbin/ntpdate time.nist.gov



	echo "Stop firewalld"
	#systemctl stop firewalld.service
}

function Install_Influxdb {
	echo "Install influxdb"
	cd ../packages
	rpm -ivh $INFLUXDB

	firewall-cmd --permanent --add-port=8083/tcp
	firewall-cmd --permanent --add-port=8086/tcp
	firewall-cmd --permanent --add-port=8090/tcp
	firewall-cmd --permanent --add-port=8099/tcp


	echo "Begin influxdb"
	/etc/init.d/influxdb start
}

function Install_Collectd {
	echo "Install collectd"

	rpm -ivh $EPEL_NAME
	yum install collectd -y

	echo "Configure collectd"
	cp $COLLECTD_CONF $COLLECTD_CONF.abk
	sed -i "13 c Hostname    \"influxdb\"" $COLLECTD_CONF
	sed -i "15 c BaseDir     \"/var/lib/collectd\"" $COLLECTD_CONF
	sed -i "16 c PIDFile     \"/var/run/collectd.pid\"" $COLLECTD_CONF
	sed -i "17 c PluginDir   \"/usr/lib64/collectd\"" $COLLECTD_CONF
	sed -i "18 c TypesDB     \"/usr/share/collectd/types.db\"" $COLLECTD_CONF
	sed -i "s/#LoadPlugin network/LoadPlugin network/g" $COLLECTD_CONF
	sed -i "s/#LoadPlugin uptime/LoadPlugin uptime/g" $COLLECTD_CONF
	sed -i "N;/#<Plugin aggregation>/i\<Plugin network>" $COLLECTD_CONF
	sed -i "218 i Server \"127.0.0.1\" \"8096\" " $COLLECTD_CONF
	sed -i "N;/#<Plugin aggregation>/i\</Plugin>" $COLLECTD_CONF

	systemctl start  collectd.service

	echo "Configure influxdb"
	cp $INFLUXDC_CONF $INFLUXDC_CONF.bak
	sed -i "50 c  enabled = true" $INFLUXDC_CONF
	sed -i "52 c  port = 8096" $INFLUXDC_CONF
	sed -i "53 c  database = \"collectd\"" $INFLUXDC_CONF
	sed -i "56 c   typesdb = \"/usr/share/collectd/types.db\"" $INFLUXDC_CONF

	/etc/init.d/influxdb restart
}

function Install_Grafana {
	echo "Install grafana"

	yum install initscripts fontconfig -y

	rpm -ivh $GRAFANA
	firewall-cmd --permanent --add-port=3000/tcp
	systemctl daemon-reload
	systemctl start grafana-server
}

Prepare_Envrionment
Install_Influxdb
echo "Create the databse whose name is collectd on the website"
read -p "Finished? [y/n]: " CHOICE
if [ $CHOICE == 'y' ]; then
	Install_Collectd
	Install_Grafana
fi 











