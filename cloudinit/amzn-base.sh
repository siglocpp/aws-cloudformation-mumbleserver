#!/bin/bash

# Usage
#
# aws s3 cp --region eu-central-1 s3://cinovo-cloudinit/amzn-base.sh - | bash

mySSHKey="enter your key here!"

# permit root login and add default ssh keys
sed -i 's/PermitRootLogin forced-commands-only/PermitRootLogin yes/g' /etc/ssh/sshd_config
/sbin/service sshd restart
echo "adding sshkeys"
cat > /root/.ssh/authorized_keys << "EOF"
$mySSHKey
EOF
echo "addeed sshkeys"
cat /root/.ssh/authorized_keys
# enable epel repo
sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/epel.repo

# install additional default packages
yum -y install bash-completion vim wget tcpdump ntpdate telnet nano

# aliases
cat >> /root/.bashrc << "EOF"
alias l='ls -lah'
alias ..='cd ..'
alias psa='ps ax -f | grep -v "0:00 \[.*\]"'
EOF

# set some kernel options and activate them
cat >> /etc/sysctl.conf << "EOF"
fs.file-max = 294180 # Allow more open files (sockets are also files) cat /proc/sys/fs/file-nr (default: 58426)
net.ipv4.tcp_timestamps=0 #Verhindern, dass TCP Timestamps gesendet werden --> Angreifer koennen daran erkennen wann das System zuletzt rebootet wurde (default: 1)
net.ipv4.icmp_echo_ignore_broadcasts = 1 # Avoid a smurf attack,  ignore ICMP messages to broadcast or multicast addresses (default: 1)
net.ipv4.icmp_ignore_bogus_error_responses = 1 # Turn on protection for bad icmp error messages (default: 1)
net.ipv4.conf.all.log_martians = 1 # Turn on and log spoofed, source routed, and redirect packets (default: 0)
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.accept_source_route = 0 # Do not accept source routing (default: 0)
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0 # Make sure no one can alter the routing tables (default: 1)
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0 # Don't act as a router, except im a nat instance (default: 1 1)
net.ipv4.conf.default.send_redirects = 0
kernel.randomize_va_space = 2 # Turn on execshild (default: ? ? 2)
net.ipv6.conf.all.disable_ipv6 = 1 #Deactivate IPv6
net.ipv6.conf.default.disable_ipv6 = 1
EOF
sysctl -p /etc/sysctl.conf

# increase file limts to allow more sockets
cat >> /etc/security/limits.conf << "EOF"
# Allow users to open more files (sockets are also files) ulimit -n as the user
*			hard	nofile		100000
*			soft	nofile		100000
*	  		hard    nproc       100000
*	    	soft    nproc       100000
EOF

# disable scatter/gather to prevent "xen_netfront: xennet: skb rides the rocket:"
ethtool -K eth0 sg off

# iptables off
service iptables stop
service ip6tables stop

# set timezone
echo "cp -f /usr/share/zoneinfo/Europe/Berlin /etc/localtime" >> /etc/rc.local

# set default region for aws cli/sdk to region of running ec2 instance
aws configure set default.region `curl -s http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`

# ec2 environment 
BASE=http://169.254.169.254/latest/meta-data/
cat > /root/ec2.sh << EOF
#!/bin/bash
export INSTANCE_ID=$(curl $BASE/instance-id)
export INSTANCE_TYPE=$(curl $BASE/instance-type)
export AMI_ID=$(curl $BASE/ami-id)
export AZ_INFO=$(curl $BASE/placement/availability-zone)
export PUBLIC_HOSTNAME=$(curl -f $BASE/public-hostname)
export PRIVATE_IP=$(curl $BASE/local-ipv4)
EOF
