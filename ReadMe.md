# icinga2 package for ipfire 2.x

This repository contains all the files needed to build an icinga2 package for ipfire.

It provides two new packages:

* icinga2 contains icinga2 and icingaweb2
* monitoring-plugins contains the standard nagios plugins and the manubulon snmp plugins.

Versions are:

* icinga2 2.8.0
* icingaweb2 2.5.0
* Monitoring plugins 2.2


The following changes are made to existing files:

* ./make.sh:	lfs/icinga2 and lfs/monitoring-plugins added to the list of packages
* ./lfs/boost	icinga2 requires program_options, so the line disabling it during build has been deleted
* ./src/config/rootfiles/common/boost updated to reflect the change from above

Although boost has been updated there is no need to replace the resulting package. The 
additional shared library is also contained in the icinga2 package.

The monitoring-plugins package contains the same nagios plugins as the nagios package, 
although maybe in other versions. To avoid conflicts the monitoring-plugins package installs
its plugins in another directorxy thanm the nagios plugin. 

# ToDo/Known Problems

* after a system updated a call to 'ldconfig /usr/lib/icinga2' may be needed.
* the manubulon plugins are currently not working due to a missing perl module.
