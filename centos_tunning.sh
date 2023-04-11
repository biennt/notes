sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
setenforce 0
echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range = 1024 65535' >> /etc/sysctl.conf
echo 'fs.file-max = 5000000' >> /etc/sysctl.conf
echo 'net.core.somaxconn = 500' >> /etc/sysctl.conf
echo '* soft nproc 65535' >> /etc/security/limits.conf
echo '* hard nproc 65535' >> /etc/security/limits.conf
echo '* soft nofile 65535' >> /etc/security/limits.conf
echo '* hard nofile 65535' >> /etc/security/limits.conf
sysctl -p
