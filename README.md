#network-graphics

This application offers an API to get and set the settings for ifconfig, iwconfig and xset, xdotool, ...

Set IP
ifconfig eth0 192.168.1.1 

Set Netmask
ifconfig eth0 netmask 255.255.255.0

Set Gateway
route add default gw 192.168.1.1

Set WLAN
Update /etc/wpa_supplicant/wp_supplicant.conf
wpa_supplicant -D wext -i wlan1 -c /etc/wpa_supplicant/wp_supplicant.conf

Set Resolution
xrandr -s 1650x1080

Get IP
os.networkInterfaces()

Get Netmask
ifconfig "$1" | sed -rn '2s/ .*:(.*)$/\1/p'

Get Gateway
ip route | awk '/default/ { print $3 }'

Get Resolutions
xrandr -q

Get WLAN Scan
rmmod r8712u
modprobe r8712u
ifconfig wlan1 up
iwlist wlan1 scan