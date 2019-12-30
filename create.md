## VirtualBox - Create a new virtual machine

* Install VirtualBox: https://virtualbox.org/

VirtalBox > New > (Expert Mode)

* Name: UbuntuDev
* Type: Linux
* Version: Ubuntu (64 bit)
* Memory size: 4096 MB
* Hard disk: No - Do not add a virtual hard disk

VirtualBox > Settings

* System
  - Motherboard > Boot Order: Optical, Hard Disk
  - Processor > CPU: 4 (Maximum of green)
* Storage (Expert mode)
  - SATA Port 0, Hard disk, File location: System, 100 GB, VDMK, Dynamically allocated
  - SATA Port 2, Compact Disc, Insert operating system
* Audio > Enable Audio: false
* Network
  - Adapter 1, NAT
  - Adapter 2, Bridged Adapter, eth1 (Your network device)

### Download Ubuntu

https://ubuntu.com/

### Installation for Ubuntu Server 16.04

* Language: English
* Install Ubuntu Server

* Language: English
* Country: United States
* Optional: Detect Keyboard Layout
* Select Primary Network interface

* Hostname: dev-vm
* Full name: user
* Username: user
* Passwort: user

* Encrypt home directory: No (Your preference)
* Time zone: Europe/Berlin (Your preference)
* Partition method: Guided - use the entire disk
  - SCSI1 (0,0,0) (sda) - 80 GB ATA VBOX HARDDISK

* HTTP proxy: (empty)
* No automatic updates
* Software
  - standard system utilities
  - OpenSSH server
* Install GRUB boot loader = Yes
* Reboot

### Installation for Ubuntu Server 18.04

* Page 1 - Language:
  - Language: English
* Page 2 - Keyboard configuration:
  - Your preference -> Identify keyboard
  - Layout: English (US)
  - Variant: English (US)
* Page 3 - Ubuntu 18.04:
  - Install Ubuntu
* Page 4 - Network connections:
  - Network configuration
* Page 5 - Configure proxy:
  - Proxy address: (empty)
* Page 6 - Configure Ubuntu archive mirror:
  - (bypass)
* Page 7 - Filesystem setup:
  - Use an Entire Disk
  - VBOX_HARDDISK_...
* Page 8 - Profile:
  - Your name: user
  - Your Server's name: dev-vm
  - Username: user
  - Passwort: user
* Page 9 - Feature Server: (bypassed)
* Page 10: (Installation running)
* Page 11: (Reboot)

## Procceed the installation

Set password for root account with password: root

```Shell
sudo passwd root
```

### Visudo: No password for user

```Shell
sudo visudo
```

Append to end in visudo file:

```text
%sudo ALL=(ALL) NOPASSWD: ALL
```

Reboot system.

### Ubuntu 16.04 Server: Configure network interfaces

```Shell
ip a
sudo vim /etc/network/interfaces
```

File: interfaces

```Shell
# The loopback network interface
auto lo
iface lo inet loopback

# Network 1 (NAT)
auto enp0s3
iface enp0s3 inet dhcp

# Network 2 (Bridged Adapter)
auto enp0s8
iface enp0s8 inet dhcp

# Network 3 (Host-only Adapter)
#auto enp0s9
#iface enp0s9 inet dhcp
```

Restart network interfaces.

```Shell
sudo ifdown -a && sudo ifup -a
```

### Repository

Install Git & clone repository.

```Shell
sudo apt -y install git
git clone https://github.com/Cyb10101/dev-vm-linux.git /home/user/dev-vm-linux
```

### Install

Run installation.

```Shell
/home/user/dev-vm-linux/create
```

* Ubuntu 18.04: Configuring console-setup: UTF-8

Now you have created a new virtual machine.

I recommend to export the virtual machine to a ova file. See following...

## Recommended: Shrink hard disk for export

Boot with a Ubuntu Live ISO and fill empty space on hard disk with zeros.
This make your exportet image smaller.

```Shell
sudo su
apt install zerofree
blkid
zerofree -v /dev/sda1
poweroff
```

## Virtualbox export

* Expert mode
* Virtualbox > File > Export Appliance
  - Open Virtualization Format 2.0

## Virtualbox import

To import a OVA file and configure the virtual machine see file [usage.md](usage.md).

## Optional: Pretest PhpBrew versions and update PHP

Update the PHP versions in the repository.

* Create Snapshot, install PHP, install PhpBrew
* Query and update available PHP versions
* Reset snapshot

```Shell
sudo apt -y install php

# Install PhpBrew

# Check available versions
phpbrew known

# Update PHP versions in repository
find . -type d -name '.git' -prune -o -type f -print -exec sed -i '' \
    -e 's/7\.3\.0/7\.3\.1/g' \
    -e 's/7\.2\.11/7\.2\.14/g' \
    -e 's/7\.1\.23/7\.1\.26/g' \
    -e 's/7\.0\.32/7\.0\.33/g' \
    -e 's/5\.6\.38/5\.6\.40/g' \
    {} \;
```
