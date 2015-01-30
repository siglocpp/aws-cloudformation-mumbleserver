#AWS Cloudformation Template for a Mumble-Server with no-ip DNS binding

These files will create an Amazon Instance for a mumble-server with no-ip support and continuous sqlite backups.
Therefore a VPC will be created and the instance will be configured.

## How-To use

###Configuration
1. Open the `/cloudinit/amzn-base.sh` file and set the mySSHKey Variable.
2. Open the `/cloudinit/mumble.sh` file and set the SUPERPW variable for the superadmin password
3. Modify the `/installs/mumble/murmur.ini` to your liking. 

**Attention**

If you changed any paths make sure you also change those paths within the following files:

`/installs/mumble/murmur` the init.d script which contains pathing to murmur, the pid file andthe ini file

`/cloudinit/mumble.sh` installation script for cloudinitialization. Creates folders and the bac
`

###AWS-Cloudformation

1. Create an Amazon-S3 Bucket with the name `cf-mumble`.
2. Upload all three folder and their content into `cf-mumble`
3. Create a stack using the `/cloudformation/mumble.json` as template. 
4. Set the ip-range and the stack name.
5. Wait

###First Start
1. Log on the machine by using our ssh key and the root account.
2. SetUp your noip configuration by entering `noip2 -C` and follow the promts



