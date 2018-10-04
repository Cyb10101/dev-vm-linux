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
