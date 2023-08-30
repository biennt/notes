#!/bin/bash
id

if [ `id -u` -ne 0 ]; then
	echo Need sudo
	exit 1
fi
set -v


# Install vmware guest tool
apt-get update
apt-get install -y open-vm-tools
apt-get clean

# Stop services for cleanup
service rsyslog stop

# Clear audit logs
if [ -f /var/log/audit/audit.log ]; then
    cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
    cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    cat /dev/null > /var/log/lastlog
fi

# Cleanup persistent udev rules
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    rm /etc/udev/rules.d/70-persistent-net.rules
fi

# Cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

# Cleanup current ssh keys
rm -f /etc/ssh/ssh_host_*

# regenerate ssh keys on next boot
cat <<EOL | sudo tee /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL

# Reset hostname
cat /dev/null > /etc/hostname

# Cleanup shell history
history -c
history -w
