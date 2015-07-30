#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/6
#Contact email:	kylinlingh@foxmail.com
#Usage:			To begin installing nagios on moniting host automatically
#Attention:	

INSTALL_DIR=/usr/local
TOOLS_NAME=tools_for_performance

yum install lrzsz -y
yum install dos2unix -y
yum install unzip -y
rm -rf $INSTALL_DIR/$TOOLS_NAME
cd $INSTALL_DIR
unzip $TOOLS_NAME.zip -d $INSTALL_DIR
cd $INSTALL_DIR/$TOOLS_NAME
dos2unix scripts/*
cd scripts/
sh auto_install_server.sh 2>&1 | tee $INSTALL_DIR/$TOOLS_NAME/log/nagios_install.log