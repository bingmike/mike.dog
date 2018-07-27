#!/bin/bash

echo Step one is to understand that this script overwrites system files
echo Uh-oh, we are already goimg.

# Typos in a previous version of this line resulted in a jacked up clock
ln -sf /usr/share/zoneinfo/America/Phoenix /etc/localtime
hwclock --systohc

cat > /etc/locale.gen << EOF
en_US.UTF-8 UTF-8
EOF
locale-gen

cat > /etc/locale.conf << EOF
LANG=en_US.UTF-8
EOF

cat > /etc/sudoers << EOF
root ALL=(ALL) ALL
mike ALL=(ALL) NOPASSWD: ALL
EOF

echo "stream14" > /etc/hostname

cat > /etc/hosts << EOF
127.0.0.1	localhost
::1		localhost
127.0.0.1	stream14.localdomain	stream14
192.168.1.3	movieroom
192.168.1.4	dijkstra
EOF

echo Set root password
passwd
groupadd mike
useradd -m -g mike -s /bin/bash mike
echo Set mike password
passwd mike
cat > /home/mike/.xinitrc << EOF
feh --bg-scale "/home/mike/images/tiedye4.jpg" &
/home/mike/scripts/dwmstatus.sh &
dwm
EOF
cat > /home/mike/.bashrc << EOF
alias ls='ls --color=auto'
alias ll='ls -l'
alias rm='rm -i'
alias mv='mv -i'
alias x='startx > /dev/null 2>&1'
setxkbmap -option ctrl:nocaps
export PS1="\\033[01;32m\\u@\\h\\033[00m \\033[01;34m\\w\\033[00m\\\\$ "
export EDITOR=vim
EOF
cat > /home/mike/.vimrc << EOF
set number
colorscheme default
set cursorline
set lazyredraw
set noshowmatch
set incsearch
set hlsearch
set nowrap
syntax on
EOF
cat > /home/mike/.profile << EOF
xset -dpms
EOF
cat > /home/mike/.conkyrc << EOF
conky.config = {
    use_xft = true,
    xftalpha = 0.8,
    update_interval = 10.0,
    total_run_times = 0,
    own_window = false,
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_class = 'conky-semi',
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    background = false,
    double_buffer = true,
    imlib_cache_size = 0,
    no_buffers = true,
    cpu_avg_samples = 2,
    override_utf8_locale = true,
    alignment = 'top_right',
    gap_x = 0,
    gap_y = 0,
    draw_shades = false,
    draw_outline = false,
    draw_borders = false,
    font = 'Tall Films:size=96',
    default_color = '202020',
};
 
conky.text = [[ \${time %l}.\${time %M}\${time %P} \${execi 20 /home/mike/scripts/conkyjuice}\${font Tall Films:size=38}
\${alignr}Wireless: \${wireless_essid wlo1} \${wireless_link_qual wlo1}% 
]];
EOF

mkdir /home/mike/images
curl http://mike.dog/tiedye4.jpg -o /home/mike/images/tiedye4.jpg

mkdir /home/mike/suckless
curl http://dl.suckless.org/dwm/dwm-6.1.tar.gz -o /home/mike/suckless/dwm.tgz
curl http://mike.dog/dwm-6.1.mj.patch -o /home/mike/suckless/dwm-6.1.mj.patch
tar xvzf dwm.tgz
patch -s -p0 < dwm-6.1.mj.patch
cd /home/mike/suckless/dwm-6.1/
make && make install
curl http://dl.suckless.org/tools/dmenu-4.8.tar.gz -o /home/mike/suckless/dmenu.tgz
tar xvzf dmenu.tgz
cd /home/mike/suckless/demenu-4.8/
make && make install
curl http://dl.suckless.org/st/st-0.8.1.tar.gz -o /home/mike/suckless/st.tgz
tar xvzf st.tgz
cd /home/mike/suckless/st-0.8.1/
make && make install

mkdir /home/mike/scripts
cat > /home/mike/scripts/dwmstatus.sh << EOF
#!/bin/bash

while true
do
	upower -i \$(upower -e|grep bat)|grep state|grep disch > /dev/null && CHARGING="v" || CHARGING="^"
	LOAD=\$(uptime|sed -e"s/ //g"|cut -d"v" -f2|cut -d":" -f2|cut -d"," -f1)
	JUICE=\$(upower -i \$(upower -e | grep BAT)|grep perc|sed -e"s/ //g"|cut -d":" -f2)
	xsetroot -name "\$(date +"%A,  %B %-d, %Y  |  %-I:%M %P")  |  \${LOAD}  |  \${JUICE}\${CHARGING}"
	sleep 10
done
EOF

chown -R mike:mike /home/mike

grub-install --target=i386-pc /dev/mmcblk0
grub-mkconfig -o /boot/grub/grub.cfg

echo Exit the chroot environment and reboot
