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
stop_service icinga2
make_backup icinga2
userdel  icinga
groupdel icinga
groupdel icingacmd
mysqldump icinga     | gzip -9 > /var/ipfire/backup/addons/backup/icinga2.dump.gz
mysqldump icingaweb2 | gzip -9 > /var/ipfire/backup/addons/backup/icingaweb2.dump.gz
echo "drop database icingaweb2" | mysql -u root -pmysqlfire 
echo "drop database icinga" | mysql -u root -pmysqlfire 
remove_files
