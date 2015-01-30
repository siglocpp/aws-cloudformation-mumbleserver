#!/bin/bash
# Usage
#
# export BUCKETNAME=foo
# curl https://raw.githubusercontent.com/taimos/route53-updater/v1.4/cloud-init/ec2-private.sh | bash
yum install -y noip

aws s3 cp s3://$BUCKETNAME/no-ip2.conf /etc/no-ip2.conf


#set up sqlite db save cronjob
cat <<EOF > /root/noipbackups3.sh
#!/bin/bash

aws s3 cp /etc/no-ip2.conf s3://$BUCKETNAME/no-ip2.conf

EOF

chmod +x /root/noipbackups3.sh

cat <<EOF > /etc/cron.d/noipbackups3
*/30 * * * * root /root/noipbackups3.sh
EOF

chmod 0644 /etc/cron.d/noipbackups3


service noip start
