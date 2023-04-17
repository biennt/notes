general

/etc/sysctl.conf
net.ipv4.ip_local_port_range = 1024 65535
fs.file-max = 5000000
net.core.somaxconn = 500
net.ipv4.ip_local_port_range = 1024 65535
fs.file-max = 5000000
net.core.somaxconn = 500
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_timestamps = 1

/etc/security/limits.conf
* soft nproc 250000
* hard nproc 250000
* soft nproc 250000
* hard nproc 250000
* soft nofile 250000
* hard nofile 250000

centos:

sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
setenforce 0



