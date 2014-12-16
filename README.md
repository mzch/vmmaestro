vmmaestro
=========

This tiny shell script can start/stop KVM virtual machines. There is the first note that this script NEVER managements VMs in all senses. It has no fail over mechanism including live migration, no beautiful GUI. You can't see any statistical information. In addition, it can't even create an new VM disk image.

vmmaestro (:D) is a simple command line tool to start, shutdown VMs and help to connect to its screen from your client PC.    

----
## Installation    
### Step 1
Clone this repository.    
### Step 2
* Copy ```vmmaestro``` to anywhere you'd like, i.e. ```/usr/local/bin/```
* Create ```/etc/vmmaestro``` directory.
    
### Step 3
If you use SPiCE and TLS, place 3 files into ```/etc/vmmaestro/ssl```.
* A PEM formatted file merged CA Root certificate with CA intermediate certificate. It must be named ```ca-cert.pem```.
* A server certificate issued by CA. It must be named ```server-ca.pem```.
* A private key file. It must be named ```server-key.pem```.

### Step 4
Install ```sudo```, ```bridge-utils``` and ```qemu-kvm``` packages.

### Step 5
* Create ```kvm``` user account if it doesn't exist.
* Add ```kvm``` user to ```sudo``` (See ```sample/etc/sudoers.d/qemu```).
* Of course, add also your account to ```sudo```.

#### Step 6
* Add TUN/tap kernel module, ```tun``` to the system. (execute '```modprobe tun```')
* Add Vhost-net kernel module, ```vhost-net``` to the system. (execute '```modprobe vhost-net```')

#### Step 7
Add bridge interfaces per NIC. Recommend to name them like '```br0```', '```br1```'...

#### Step 8
* Create the global configuration file, ```/etc/vmmaestro/vmmaestro.conf``` (See ```vmmaestro.conf.sample```).
* Create the VM specific configuration file in ```/etc/vmmaestro```. The base name of it must be the same name as VM and has the extension, '```.conf```'.
* You can put all settings in the VM specific configuration file and leave blank the global configuration. However, I recommend to put as many common settings as possible in the global configuration file. When the same item in both file, **the one put into the VM specific configuration is given priority**.

#### Step 9
Create acl file for bridge interfaces in ```/etc/qemu```. (See ```sample/etc/qemu/bridge.conf```)

#### Step 10
Create lvm partitions or files for VM as you specified in the vm config file(s).

#### Step 11
Type ```vmmaestro start vm-name``` and enjoy!

----
## Reference    
#### vmmaestro consolestart VM
start VM and then connect to serial console.

#### vmmaestro start [VM [VM [VM]...]]
start VMs. This command can boot multiple VMs.

#### vmmaestro shutdown [VM [VM [VM]...]]
shutdown VMs. When entering this command, VMs will do shutdown sequences.

#### vmmaestro stop [VM [VM [VM]...]]
stop VMs. When entering this command, VMs will terminate immediately
#### vmmaestro kill [VM [VM [VM]...]]
kill kvm process directly.

#### vmmaestro restart [VM [VM [VM]...]]
Reboot VMs.

#### vmmaestro status [VM [VM [VM]...]]
If VM is running, shows the message, "```VM name is running.```".
Otherwise shows the message, "```VM name is stopped.```"

#### vmmaestro console VM
Connect serial port and show local text screen. 

#### vmmaestro monitor VM
Connect KVM/QEMU monitor port.

----
## Hint    
* By default, VNC & SPICE port is bind to localhost address (127.0.0.1). I recommend use ```SSH tunneling``` instead of changing bind address.
