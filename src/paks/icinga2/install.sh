#!/bin/bash
############################################################################
#                                                                          #
# This file is part of the IPFire Firewall.                                #
#                                                                          #
# IPFire is free software; you can redistribute it and/or modify           #
# it under the terms of the GNU General Public License as published by     #
# the Free Software Foundation; either version 2 of the License, or        #
# (at your option) any later version.                                      #
#                                                                          #
# IPFire is distributed in the hope that it will be useful,                #
# but WITHOUT ANY WARRANTY; without even the implied warranty of           #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
# GNU General Public License for more details.                             #
#                                                                          #
# You should have received a copy of the GNU General Public License        #
# along with IPFire; if not, write to the Free Software                    #
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA #
#                                                                          #
# Copyright (C) 2007 IPFire-Team <info@ipfire.org>.                        #
#                                                                          #
############################################################################
#
. /opt/pakfire/lib/functions.sh
extract_files
ldconfig /usr/lib/icinga2
groupadd icinga
groupadd icingacmd
groupadd icingaweb2
useradd  -c incinga -s /sbin/nologin -G icingacmd -g icinga icinga
usermod  -a -G icingacmd  nobody
usermod  -a -G icingaweb2 nobody
echo "CREATE DATABASE icinga; GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON icinga.* TO 'icinga'@'localhost' IDENTIFIED BY 'icinga';" | mysql -u root -pmysqlfire
mysql -u root -pmysqlfire icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql
echo "CREATE DATABASE icingaweb2; GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON icingaweb2.* TO 'icingaweb2'@'localhost' IDENTIFIED BY 'icingaweb2';" | mysql -u root -pmysqlfire
mysql -u root -pmysqlfire icingaweb2 < /usr/share/icingaweb2/etc/schema/mysql.schema.sql
chown -R nobody /etc/icinga /etc/icingaweb2
chown -R icinga /var/cache/icinga2
chown -R icinga /var/lib/icinga2
chown -R icinga /var/log/icinga2
chown -R icinga /var/spool/icinga2
icinga2 api setup
if [ 0 == fgrep -c icingaweb2 /etc/icinga2/conf.d/api-users.conf ] ; then
pwd=`openssl rand -base64 32`
cat >> /etc/icinga2/conf.d/api-users.conf << 'EOF'

object ApiUser "icingaweb2" {
  password = "${pwd}"
  permissions = [ "status/query", "actions/*", "objects/modify/*", "objects/query/*" ]
}
EOF
cat > /etc/icingaweb2/modules/monitoring/commandtransports.ini << 'EOF'
[icinga2]
transport = "api"
host      = "localhost"
port      = "5665"
username  = "icingaweb2"
password  = "${pwd}"
EOF
fi

sed -i -e/;date.timezone =/date.timezone = 'Europe\/Berlin'/ /etc/php.ini

pwd=`openssl passwd -1 iw2IpF1re`
echo "INSERT INTO icingaweb_user (name, active, password_hash) VALUES ('icingaadmin', 1, '${pwd}');" | mysql -u icingaweb2 -picingaweb2 icingaweb2

restore_backup icinga2
start_service icinga2

