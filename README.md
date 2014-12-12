vmmaestro
=========

Thsi tiny shell script is for controlling KVM. There is the first note that this script NEVER managements VMs in all senses. It has no fail over mechanism including live migration, no beautiful GUI. You can't see any statistical information. In addition, it can't even create an new VM disk image.

vmmaestro (:D) is a simple command line tool to start, shutdown VMs and help to connect to its screen from your client PC.    

----
## Instllation    
### Step 1
clone repogitory.    
### Step 2
* Copy vmmaestor, which is a shell script, to anywhere you'd like, i.e. /usr/local/bin/
* Create ```/etc/vmmaestro``` directory.
* Copy ifup.sh & ifdown.sh to ```/etc/vmmaestro```
* Create global configuration file, ```/etc/vmmaestro/vmmaestro.conf``` by using ```vmmaestro.conf.sample```
    
### Step 3
If you will use SPiCE and TLS, place 3 files into ```/etc/vmmaestro/ssl```.
* ca-cert.pem, this is a merged file with CA Root certificate and CA intermediate certificate.
* server-ca.pem, this is a server certificate.
* server-key.pem, this is a private key file.

### Step 4
You must install ```sudo```, ```brctl``` package and ```qemu-kvm``` packages.

### Step 5
* if not created ```kvm``` user or other, add ```kvm``` user account.
* Add ```kvm``` user to /etc/sudoers (this repo includes a sample settings).

#### Step 6
* create volume group and lvm partitions as you prefer.

#### Step 7
* create VM spefcific configuration file in ```/etc/vmmaestro```. The file name must be the same name as VM and an extension is '.conf'

#### Step 8
* Add TUN/tap kernel module, ```tun``` to the system. (```modprobe tun```)

#### Step 9
* Add bridge interface per NIC. Recommend to name a bridge like '```br0```', '```br1```'...

#### Step 10
* Type ```vmmaestro start vm-name``` and enjoy!

----
## Reference    
#### vmmaestro start [VM [VM [VM]...]]
start VMs. This command can boot multiple VMs.

#### vmmaestro shutdown [VM [VM [VM]...]]
shutdown VMs. When entering this command, VMs will do shutdown sequences.

#### vmmaestro stop [VM [VM [VM]...]]
stop VMs. When entering this command, VMs will terminate immediately.

#### vmmaestro kill [VM [VM [VM]...]]
kill kvm process directly.

#### vmmaestro restart [VM [VM [VM]...]]
Reboot VMs.

#### vmmaestro status [VM [VM [VM]...]]
If VM is running, shows the message, "```VM name is running.```".
Otherwise shows the message, "```VM name is stopped.```"