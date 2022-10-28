vmmaestro
=========

This tiny shell script can start/stop KVM virtual machines. There is the first note that this script NEVER managements VMs in all senses. It has no fail over mechanism or live migration, no beautiful GUI. You can't see any statistical informations. In addition, it can't even create an new VM disk image.

vmmaestro (:D) is a simple command line tool to start, shutdown VMs and help to connect to the screens from your client PC.    

----
## Installation    
### Step 1
Clone this repository.    
### Step 2
* Copy `vmmaestro` to anywhere you'd like, i.e. `/usr/local/bin/`
* Give executable permission to `vmmeastro`, i.e. `chmod +x /usr/local/bin/vmmaestro`
* Create `/etc/vmmaestro` directory.
    
### Step 3
If you use SPiCE and TLS, place 3 files into `/etc/vmmaestro/ssl`.

* CA Root certificate in PEM format. It must be named `ca-cert.pem`.
* A server certificate merged with CA intermediate certificate issued by CA. It must be named `server-ca.pem`.
* A private key file. It must be named `server-key.pem`.

### Step 4
Install `socat`, `sudo`, `bridge-utils` and `qemu-kvm` packages.

### Step 5
* Create `kvm` user account if it doesn't exist.
* Add `kvm` user to `sudo` (See `sample/etc/sudoers.d/qemu`).
* Of course, add also your account to `sudo`.

#### Step 6
* Add KVM kernel module. (execute `modprobe kvm`)
* Add TUN/tap kernel module, `tun` to the system. (execute '`modprobe tun`')
* Add Vhost-net kernel module, `vhost-net` to the system. (execute '`modprobe vhost-net`')
* Add entries above into `/etc/modules` if necessary.

#### Step 7
Add bridge interfaces per NIC. Recommend to name them like '`br0`', '`br1`'...

#### Step 8
* Create the global configuration file, `/etc/vmmaestro/vmmaestro.conf` (See `vmmaestro.conf.sample`).
* Create the VM specific configuration file in `/etc/vmmaestro/vms`. The base name of it must be the same name as VM and has the extension, '`.conf`'. You can change `vms` directory in `/etc/vmmaestro/vmmaestro.conf`.
* You can put all settings in the VM specific configuration file and leave blank the global configuration. However, I recommend to put as many common settings as possible in the global configuration file. When the same item in both file, **the one put into the VM specific configuration is given priority**.

#### Step 9
Create acl file for bridge interfaces in `/etc/qemu`. (See `sample/etc/qemu/bridge.conf`)

#### Step 10
Create lvm partitions or files for VM as you specified in the vm config file(s).

#### Step 11
Type `vmmaestro start vm-name`and enjoy!

----
## Reference
#### vmmaestro [-r|--reverse] consolestart [VM...]
start VM and then connect to serial console. No specified VM will start all VMs in order.

#### vmmaestro [-r|--reverse] start [VM...]
start VMs. This command can boot multiple VMs. No specified VM will start all VMs in order.

#### vmmaestro [-r|--reverse] shutdown [VM...]
shutdown VMs. When entering this command, VMs will do shutdown sequences. No specified VM will shutdown all VMs in order.

#### vmmaestro [-r|--reverse] stop [VM...]
stop VMs. When entering this command, VMs will terminate immediately. No specified VM will stop all VMs in order.
#### vmmaestro kill [VM...]
kill kvm process directly. No specified VM will kill all VMs in order.

#### vmmaestro [-r|--reverse] restart [VM...]
Reboot VMs. No specified VM will restart all VMs in order.

#### vmmaestro [-r|--reverse] status [VM...]
If VM is running, shows the message, "`VM name is running.`".
Otherwise shows the message, "`VM name is stopped.`".
No specified VM will show all VMs' status in order.

#### vmmaestro [-r|--reverse] list [VM ...]
Show status and configurations of VMs. No specified VM will list all VMs in order.

#### vmmaestro [-r|--reverse] console [VM ...]
Connect VM's serial port. No specified VM will connect all VMs' ports in order.

#### vmmaestro [-r|--reverse] monitor [VM ...]
Connect KVM/QEMU monitor port. No specified VM will connect all VMs' monitors in order.

#### vmmaestro help
Print usage.

※ When no VM and `-r`,`--reverse` option is specified, `vmmaestro` will search VMs in reverse.

#### Envoronment Variables
If setting `VMM_DELAY` environment variable, `vmmaestro` will insert specified seconds delay between earch VM.

----
## Hint    
* By default, VNC & SPICE port is bind to localhost address (127.0.0.1). I recommend to use `SSH tunneling` instead of changing bind address.
