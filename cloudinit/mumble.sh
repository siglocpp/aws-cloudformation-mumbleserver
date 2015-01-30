#!/bin/bash

SUPERPW="ADD PASSWORD HERE"
INIFILE=/etc/murmur.ini

cd /tmp

# get the package and extract it
aws s3 cp s3://cf-mumble/installs/mumble/murmur-static_x86-1.2.8.tar.bz2 .
tar -vxjf ./murmur-static_x86-1.2.8.tar.bz2
mkdir /usr/local/murmur
cp -r ./murmur-static_x86-1.2.8/* /usr/local/murmur/

# get the config file
aws s3 cp s3://cf-mumble/installs/mumble/murmur.ini /etc/murmur.ini

# add mumble grp
groupadd -r murmur
useradd -r -g murmur -m -d /var/lib/murmur -s /sbin/nologin murmur
mkdir /var/log/murmur
chown murmur:murmur /var/log/murmur
chmod 0770 /var/log/murmur

mkdir /var/run/murmur
chown murmur:murmur /var/run/murmur
chmod 0770 /var/run/murmur

mkdir /var/db/murmur
chown murmur:murmur /var/db/murmur
chmod 0770 /var/db/murmur


#get the init.d file
aws s3 cp s3://cf-mumble/installs/mumble/murmur /etc/init.d/murmur
chmod 0755 /etc/init.d/murmur

cd /usr/local/murmur/
./murmur.x86 -ini INIFILE -supw $SUPERPW

#get the sqlite db
aws s3 cp  s3://$BUCKETNAME/murmur.sqlite /var/db/murmur/murmur.sqlite
chown murmur:murmur /var/db/murmur/murmur.sqlite

#set up sqlite db save cronjob
cat <<EOF > /root/backups3.sh
#!/bin/bash

aws s3 cp /var/db/murmur/murmur.sqlite s3://$BUCKETNAME/murmur.sqlite

EOF

chmod +x /root/backups3.sh

cat <<EOF > /etc/cron.d/backups3
*/30 * * * * root /root/backups3.sh
EOF

chmod 0644 /etc/cron.d/backups3

#start murmur
service murmur restart

