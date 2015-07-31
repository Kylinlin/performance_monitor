#!/bin/bash
#Arthor:		Kylin
#Loaction:		Guangzhou
#Date:			2015年7月30日
#Usage:			一键安装collectd+influxdb+grafana性能监控系统

. /etc/rc.d/init.d/functions


TOOLS_LOCATION=/tmp
TOOLS_NAME=tools_for_performance
ARCHIVE_LOCATION=$TOOLS_LOCATION/$TOOLS_NAME/tools

INFLUXDB_NAME=influxdb-0.8.8-1.x86_64.rpm
EPEL_NAME=epel-release-7-5.noarch.rpm
COLLECTD_CONF=/etc/collectd.conf
INFLUXDC_CONF=/opt/influxdb/shared/config.toml


echo "Setting timezone"
timedatectl set-timezone Asia/Shanghai
/usr/sbin/ntpdate time.nist.gov

echo "Stop firewalld"
systemctl stop firewalld.service


echo "Install influxdb"
cd $ARCHIVE_LOCATION
rpm -ivh $INFLUXDB_NAME

echo "Begin influxdb"
/etc/init.d/influxdb start

echo "Install collectd"
cd $ARCHIVE_LOCATION
rpm -ivh $EPEL_NAME
yum install collectd -y

echo "Configure collectd"
cp /etc/collectd.conf /etc/collectd.conf_backup
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
cp /opt/influxdb/shared/config.toml /opt/influxdb/shared/config.toml_backup
sed -i "50 c  enabled = true" $INFLUXDC_CONF
sed -i "52 c  port = 8096" $INFLUXDC_CONF
sed -i "53 c  database = \"collectd\"" $INFLUXDC_CONF
sed -i "56 c   typesdb = \"/usr/share/collectd/types.db\"" $INFLUXDC_CONF

/etc/init.d/influxdb restart

echo "Install grafana"

yum install initscripts fontconfig -y
cd $ARCHIVE_LOCATION
rpm -ivh grafana-2.0.2-1.x86_64.rpm
systemctl daemon-reload
systemctl start grafana-server







