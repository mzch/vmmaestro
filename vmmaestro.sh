#! /bin/bash
################################################################################
#
#  vmmaestro - Tiny KVM wrapper shell script
#
#  Copyright (C) 2014 Koichi MATSUMOTO.  All rights reserved.
#
################################################################################
#E=echo

use_sudo='y'

########################################
#### Directory
########################################

SYSDIR=/etc/vmmaestro

boot_qemu_delay=5

########################################
#### check args
########################################

if [[ $# != 2 ]]; then
  echo 'Usage: '$0' [start|stop|shutdown|restart|kill|console|monitor|status] vm-name,...'
  exit 1
fi

########################################
#### create startup command line
########################################
##############################
#### create CPU
##############################
function create_cpu
{
  if [[ x$vmodel == x ]]; then
      vmodel='kvm64'
  fi
  cpu_arg='-cpu='$vmodel' -smp '$vcore',cores='$vcore',threads='$vthread',sockets='$vsocket
}

##############################
#### creete drive args
##############################
function create_disk_drive
{
  disk_args=
  idx=0
  while [[ x${disk[$idx]} != x ]];
  do
    if [[ x$diskvg != x ]]; then
        disk_dev=/dev/$diskvg/${disk[$idx]}
        if [[ ! -b $disk_dev ]]; then
            echo "Specified block device does not exist: "${disk[$idx]}
            exit 10
        fi
    else
        disk_dev=${disk[$idx]}
        if [[ ! -f $disk_dev ]]; then
            echo "Specified disk file does not exist: "$disk_dev
            exit 10
        fi
    fi
    disk_args=$disk_args' -drive file='$disk_dev',if='$disk_if',format='$disk_fmt',index='$idx',media=disk' 
    ((idx=idx+1))
  done
}

##############################
#### CD-ROM
##############################
function create_cdrom {
  cd_args=
  if [[ x$iso != x ]]; then
    if [[ ! -f $iso ]]; then
        echo "Specified iso file does not exist."
        exit 11
    fi
    cd_args='-cdrom '$iso
  fi
}

##############################
#### creete floppy disk
##############################
function create_floppy
{
  fd_args=
  idx=0
  while [[ x${floppy[$idx]} != x ]];
  do
    fd_file=${floppy[$idx]}
    if [[ ! -f $fd_file ]]; then
        echo "Specified floppy file does not exist: "$fd_file
        exit 12
    fi
    fd_args=$fd_args' -drive file='$fd_file',if=floppy,index='$idx
    ((idx=idx+1))
  done
}

##############################
#### Network
##############################
function create_network_adaptor
{
  net_args=
  idx=0
  while [[ x${nic_type[$idx]} != x ]];
  do

    nic_arg='-net nic'
    if [[ ${nic_vlan[$idx]} ]]; then
      nic_arg=$nic_arg',vlan='${nic_vlan[$idx]}
    fi
    if [[ ${nic_addr[$idx]} ]]; then
      nic_arg=$nic_arg',macaddr='${nic_addr[$idx]}
    fi
    nic_arg=$nic_arg',model='${nic_type[$idx]}
    if [[ ${nic_name[$idx]} ]]; then
      nic_arg=$nic_arg',name='${nic_name[$idx]}
    fi
    net_args=$net_args' '$nic_arg

    nic_arg='-net tap'
    if [[ ${nic_vlan[$idx]} ]]; then
      nic_arg=$nic_arg',vlan='${nic_vlan[$idx]}
    fi
    nic_arg=$nic_arg',ifname='${nic_bridge[$idx]}
    nic_arg=$nic_arg',script='$VMNICUP',downscript='$VMNICDOWN
    net_args=$net_args' '$nic_arg

    ((idx=idx+1))
  done
}

##############################
#### Display
##############################
function create_display
{
  if [[ x$display == x ]]; then
    display='vnc'
  fi
  case "$display" in
    vnc)
      disp_args='-vnc '$vnc_bind:$vnc_display
      ;;
    spice)
      disp_args='-spice sasl,tls-port='$spice_port',x509-dir='$SSLDIR
      ;;
    *)
      echo 'Illegal display: '$display
      exit 14
      ;;
  esac
  disp_args=$disp_args' -vga '$vga_type
}

##############################
#### Keyboard
##############################
function create_kbd
{
  kbd_args=
  if [[ x$lang != x ]]; then
    kbd_args='-k '$lang
  fi
}

##############################
#### Keyboard
##############################
function create_rtc
{
  rtc_args='-rtc'
  if [[ $use_utctime == 'n' ]]; then
    rtc_args=$rtc_args' base=localtime'
  else
    rtc_args=$rtc_args' base=utc'
  fi
  if [[ $sync_host == 'n' ]]; then
    rtc_args=$rtc_args',clock=vm'
  else
    rtc_args=$rtc_args',clock=host'
  fi
}

##############################
#### Create Run Directory
##############################
function create_rundir
{
    vmrundir=$RUNDIR/$vm
    if [[ ! -d $vmrundir ]]; then
        $SUDO mkdir -p $vmrundir
        $SUDO chown $runas:$runas $vmrundir
    fi
}

##############################
#### Serial Port Socket
##############################
function get_serial
{
  serial_port=$RUNDIR/$vm/serial.sock
}

##############################
#### Monitor Port Socket
##############################
function get_monitor
{
  monitor_port=$RUNDIR/$vm/monitor.sock
}

##############################
#### PID file
##############################
function get_pid_file
{
  pid_file=$RUNDIR/$vm/$vm.pid
}

##############################
#### Serial & Monitor
##############################
function create_console
{
  get_serial
  s_args='-serial unix:'$serial_port',server,nowait'
  get_monitor
  m_args='-monitor unix:'$monitor_port',server,nowait'
  console_args=$s_args' '$m_args
}

#############################
#### Build Command Line
#############################
function build_cmdline
{
  create_cpu
  create_disk_drive
  create_cdrom
  create_floppy
  create_network_adaptor
  create_display
  create_kbd
  create_console
  create_rtc
  get_pid_file

  CMDLINE=$QEMU' -enable-kvm -daemonize -runas '$runas' '$cpu_args
  CMDLINE=$CMDLINE' '$disk_args' '$cd_args' '$fd_args
  CMDLINE=$CMDLINE' '$net_args' '$kbd_args
  CMDLINE=$CMDLINE' '$disp_args' '$console_args' '$rtc_args
  CMDLINE=$CMDLINE' -pidfile '$pid_file

  if [[ x$args != x ]]; then
    CMDLINE=$CMDLINE' '$args
  fi
}

########################################
### Read configuration
########################################
function read_conf
{
  declare -A drive
  declare -A floppy
  declare -A nic_type
  declare -A nic_addr
  declare -A nic_name
  declare -A nic_bridge

  def_conf=$SYSDIR/vmmaestro.conf

  if [ ! -f $def_conf ]; then
    echo You must place vmmaestro.conf in $SYSDIR
    exit 3
  fi
  . $def_conf

  vm_conf=$SYSDIR/$vm.conf

  if [ ! -f $vm_conf ]; then
    echo You must place $vm.conf in $SYSDIR
    exit 3
  fi
  . $vm_conf
}

########################################
### Destroy configuration
########################################
function del_conf
{
  unset vm
  unset vmodel
  unset vcpu
  unset vthread
  unset vsocket
  unset vmem
  unset nic_type
  unset nic_addr
  unset nic_name
  unset nic_bridge
  unset diskvg
  unset disk_if
  unset disk_fmt
  unset iso
  unset lang
  unset runas
  unset vm
  unset drive
  unset floppy
  unset display
  unset spice_port
  unset vnc_display
  unset use_utctime
  unset sync_host
  unset runas
  unset SASL_CONF_PATH
  unset SSLDIR
}

########################################
### Is running process
########################################
function proc_check
{
  get_pid_file

  $SUDO kill -0 `$SUDO cat $pid_file`
}

########################################
### start vm
########################################
function start_vm
{
  create_rundir

  build_cmdline
  $E $SUDO $CMDLINE

  delay=0

  proc_check
  while [[ ($?) && $delay < $boot_qemu_delay ]];
  do
    sleep 1
    proc_check
  done

  if [[ $boot_qemu_delay == $delay ]]; then
      echo Failed to start $vm
      exit 20
  fi
}

########################################
### shutdown vm
########################################
function shutdown_vm
{
  get_monitor
  echo system_powerdown | $SUDO socat - UNIX-CONNECT:$monitor_port
  proc_check
  while [[ ! $? ]];
  do
    sleep 1
    proc_check
  done
}

########################################
### stop vm
########################################
function stop_vm
{
  get_monitor
  echo quit | $SUDO socat - UNIX-CONNECT:$monitor_port
  proc_check
  while [[ ! $? ]];
  do
    sleep 1
    proc_check
  done
}

########################################
### stauts
########################################
function status_vm
{
  echo -n $vm" "
  proc_check
  if [[ ! $? ]]; then
    echo is running.
  else
    echo is stopped.
  fi
}

########################################
### main
########################################

if [[ $use_sudo == 'y' ]]; then
  SUDO='sudo'
fi

cmd=$1
shift

while [[ "$1" ]]; do
  vm=$1
  read_conf
  case "$cmd" in
    console|serial|serial0)
      echo For reasons unknown, ^O is the panic button.
      $SUDO socat -,raw,echo=0,escape=0x0f UNIX-CONNECT:$drawer/serial0.sock
      ;;
    monitor|kvm|qemu)
      echo For reasons unknown, ^O is the panic button.
      $SUDO socat -,raw,echo=0,escape=0x0f UNIX-CONNECT:$drawer/qemu.sock
      ;;
    start)
      start_vm
      ;;
    stop)
      stop_vm
      ;;
    shutdown)
      shutdown_vm
      ;;
    restart)
      shutdown_vm
      start_vm
      ;;
    kill)
      get_pid_file
      $SUDO kill -KILL `cat $pid_file`
      ;;
    status)
      status_vm
      ;;
    *)
      echo "Unknown command: "$cmd. >&2
      exit 2
      ;;
  esac
  del_conf
  shift
done
