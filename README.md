# intel-turbo-boost

dis-/enable Intel turbo-boost

## Installation
    
    sudo cp turbo-boost.sh /usr/local/sbin/
    sudo chmod +x /usr/local/sbin/turbo-boost.sh
    sudo mkdir -p /usr/share/icons/turbo-boost
    sudo cp icons/*.png /usr/share/icons/turbo-boost/
    sudo cp toggle-turbo-boost.desktop /usr/share/applications/toggle-turbo-boost.desktop
    
  allow the execution without password in `/etc/sudoers` with:

      # Allow command for my user without password         
      my_username_here ALL = NOPASSWD: /usr/local/sbin/turbo-boost.sh

Now press SUPER and search for "Toggle Turbo Boost", you will see the icon. Then right click to "Add to Favorites" which will add a button in the quick-start bar.

On the console, now you can call:

    sudo turbo-boost.sh disable
    sudo turbo-boost.sh enable
    sudo turbo-boost.sh toggle
    sudo turbo-boost.sh status

## Automatically disable turbo-boost on startup

If you want to autostart this 4 minutes after boot, create a systemd startup script with a delay of 240 seconds:

    sudo cp turbo-boost-disable.service /etc/systemd/system/turbo-boost-disable.service

Update systemd with:

    sudo systemctl daemon-reload
    sudo systemctl enable turbo-boost-disable


## Thanks to

http://notepad2.blogspot.com/2014/11/a-script-to-turn-off-intel-cpu-turbo.html
