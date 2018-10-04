# Development environment as a virtual machine

This tutorial will create a virtual machine that includes Linux with the Ubuntu Desktop distribution.

Why a desktop version? Because it should be as easy as possible for the users.

Licence: Public Domain - Feel free to use it, but you can also improve this.

## Try it

Notes:

* URL and VM can change through development
* Keyboard layout is set to german

Downloads:

* Ubuntu 18.04, PHP <= 7.0, Docker edge:
  - https://netslum.de/download/dev-vm-linux/UbuntuDev2018Server.ova
  - https://netslum.de/download/dev-vm-linux/UbuntuDev2018Desktop.ova

* Ubuntu 16.04, PHP <= 5.4, Docker stable:
  - https://netslum.de/download/dev-vm-linux/UbuntuDev2016Server.ova
  - https://netslum.de/download/dev-vm-linux/UbuntuDev2016Desktop.ova

## Create a virtual machine

To develop a own virtual machine from scratch see file [create.md](create.md).

## Usage of virtual machine

To import a OVA file and configure the virtual machine see file [usage.md](usage.md).

### I need a desktop!

No you don't... Maybe not recommended.

For those who need a desktop on the server, you can install one of the following packages.

Run desktop installation:

```Shell
/home/user/dev-vm-linux/desktop.sh
```

### Autologin

Forces auto login. Maybe not recommended.

```Shell
sudo systemctl edit getty@tty1
```

Add in "getty@tty1" file:

```ini
[Service]
Type=idle
ExecStart=
ExecStart=-/sbin/agetty --autologin user --noclear %I 38400 linux
```
