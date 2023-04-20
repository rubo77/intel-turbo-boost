#!/bin/bash

DESKTOP_ICON=/usr/share/applications/toggle-turbo-boost.desktop

STATE_FILE=/var/tmp/toggle-boost-state
A=$1

is_root () {
    return $(id -u)
}

run_with_sudo() {
    local prompt
    prompt=$(sudo -nv 2>&1)
    if [ $? -eq 0 ]; then
        # the current user has sudo and the password is already set
        if [ "$(whoami)" != "root" ]; then
            # restart script as root
            exec sudo su - <<EOF
                "$0" "$A"
EOF
            exit
        fi
    elif echo $prompt | grep -q '^sudo:'; then
        echo "the current user has sudo but needs the password entered"
        return 1
    else
        echo "the current user has no sudo rights"
        return 1
    fi
}

if ! is_root && ! run_with_sudo; then
    echo "Error: need to call this script with sudo or as root!"         
    exit 1
else
    if [ -f $STATE_FILE ]; then
        cat $STATE_FILE
    fi
fi

modprobe msr
if [[ -z $(which rdmsr) ]]; then
    echo "msr-tools is not installed. Run 'sudo apt-get install msr-tools' to install it." >&2
    exit 1
fi
if [ "$A" == "" ]; then
    A=toggle
fi
if [[ ! -z "$A" && "$A" != "toggle" && "$A" != "enable" && "$A" != "disable"  && "$A" != "status" ]]; then
    if [[ "$A" != "-h" &&  "$A" != "--help" ]]; then
        echo "Invalid argument: $A" >&2
        echo ""
    fi
    echo "Usage: $(basename $0) [disable|enable|toggle|status]"
    exit 1
fi
cores=$(cat /proc/cpuinfo | grep processor | awk '{print $3}')
initial_state=$(rdmsr -p1 0x1a0 -f 38:38)
echo "$A turbo boost..."
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
if [[ $state -eq 1 ]]; then
    echo "last state: disabled">$STATE_FILE
else
    echo "last state: enabled">$STATE_FILE
fi
# sleep 1
