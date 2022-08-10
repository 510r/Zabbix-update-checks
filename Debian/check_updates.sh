#!/usr/bin/env bash


PATH=/bin:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

timestamp_file="/run/zabbix/caendra_check_update"
update_interval="86400" # 1 day
timestamp_file_mtime="0"
os="debian"
epoch=$(date "+%s")
tmpfile=$( mktemp --tmpdir=/run/zabbix )    
outfile="/run/zabbix/zabbix.count.updates"

function _check_last_update {
    if [[ ! -e $timestamp_file ]]; then 
        export update_needed=y
        touch $timestamp_file
    else
        timestamp_file_mtime=$(stat -c %Y $timestamp_file )
    fi

    if [[ "$((epoch-timestamp_file_mtime))" -gt "$update_interval" ]]; then 
        export update_needed=y
    else
        export update_needed=n
    fi
}


function _check_OS_upgrades {
    if [[ "$os" == "debian" ]]; then 
        if [[ "$update_needed" == "y" ]]; then
            apt-get upgrade -s | grep -i security
            touch $timestamp_file
        fi

        pkg_to_update=$((apt-get upgrade --simulate 2>&1 | wc -l) || true)
    fi

}

_check_last_update
pkg_to_update=""
_check_OS_upgrades
echo "$pkg_to_update" > $outfile
