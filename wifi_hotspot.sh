#!/bin/sh
#
# Sets up a wireless hotspot using hostapd and udhcpd
# Must be root. Also you must configure hostapd and udhcpd yourself.
#
# (c) 2012 Carlos E. Torchia <ctorchia87@gmail.com> (GPL2)
#

# Set up forwarding and filters (gotta protect the system)
function setup_forwarding {
	/sbin/iptables -F

	echo "Adding port filters to iptables"
	echo 1 > /proc/sys/net/ipv4/ip_forward

	# HTTP
	/sbin/iptables -v -A INPUT -i lo -p tcp --dport 80 -j ACCEPT

	# DHCP
	/sbin/iptables -v -A INPUT -p tcp --dport 67:68 -j ACCEPT

	# User ports
	/sbin/iptables -v -A INPUT -i lo -p tcp --dport 1024:32767 -j ACCEPT

	# Do network address translation (NAT) for hotspot
	/sbin/iptables -v -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	/sbin/iptables -v -A FORWARD -i wlan0 -j ACCEPT

	# Drop anything else
	/sbin/iptables -v -A INPUT -p tcp --dport 0:32767 -j DROP
}

# Sets up the wireless ethernet adapter
function setup_wlan {
	ifdown wlan0
	ifconfig wlan0 192.168.27.1
}

# Turn off the hotspot
function stop {
	/etc/init.d/hostapd stop
	/etc/init.d/udhcpd stop
	/etc/init.d/iptables start
	ifdown wlan0
	/etc/init.d/wicd start
}

# Turn on the hotspot
function start {
	/etc/init.d/wicd stop
	setup_wlan
	setup_forwarding
	/etc/init.d/hostapd start
	/etc/init.d/udhcpd start
}

# Start or stop the hotspot
if [ -z "$1" -o "_$1" == "_start" ]; then
	start
elif [ "_$1" == "_stop" ]; then
	stop
fi

