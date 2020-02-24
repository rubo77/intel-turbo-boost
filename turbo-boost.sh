#!/bin/bash

DESKTOP_ICON=/usr/share/applications/toggle-turbo-boost.desktop

is_root () {
    return $(id -u)
}

has_sudo() {
    local prompt

    prompt=$(sudo -nv 2>&1)
    if [ $? -eq 0 ]; then
    	# has_sudo__pass_set
	return 0
    elif echo $prompt | grep -q '^sudo:'; then
    	# has_sudo__needs_pass"
	return 0
    else
	echo "no_sudo"
	return 1
    fi
}

if ! is_root && ! has_sudo; then
    echo "Error: need to call this script with sudo or as root!"         
    exit 1
fi

modprobe msr
if [[ -z $(which rdmsr) ]]; then
    echo "msr-tools is not installed. Run 'sudo apt-get install msr-tools' to install it." >&2
    exit 1
fi

if [[ ! -z "$1" && "$1" != "toggle" && "$1" != "enable" && "$1" != "disable"  && "$1" != "status" ]]; then
    echo "Invalid argument: $A" >&2
    echo ""
    echo "Usage: $(basename $0) [disable|enable|toggle|status]"
    exit 1
fi
A=$1
cores=$(cat /proc/cpuinfo | grep processor | awk '{print $3}')
initial_state=$(rdmsr -p1 0x1a0 -f 38:38)
for core in $cores; do
    if [[ $A == "toggle" ]]; then
        echo -n "state was "
	if [[ $initial_state -eq 1 ]]; then
            echo "disabled"
	    A="enable"
	else
	    echo "enabled"
	    A="disable"
        fi
    fi
    if [[ $A == "disable" ]]; then
        wrmsr -p${core} 0x1a0 0x4000850089
        sed -i s/cpu.*png/cpu_cold.png/g $DESKTOP_ICON
    fi
    if [[ $A == "enable" ]]; then
        wrmsr -p${core} 0x1a0 0x850089
        sed -i s/cpu.*png/cpu_hot.png/g $DESKTOP_ICON
    fi
    state=$(rdmsr -p${core} 0x1a0 -f 38:38)
    if [[ $state -eq 1 ]]; then
        echo "core ${core}: disabled"
    else
        echo "core ${core}: enabled"
    fi
done
